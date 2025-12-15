#!/bin/bash

# Crash 分析脚本
# 用法: analyze_crash.sh <ips_file>
# 例如: analyze_crash.sh "YaoYao WatchKit App-2025-11-27-192309.ips"

# 获取脚本所在目录（这样即使移动脚本也能找到 Swift 文件）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Swift 文件路径
CONVERT_SCRIPT="$SCRIPT_DIR/convertFromJSON.swift"
SYMBOLICATE_SCRIPT="$SCRIPT_DIR/symbolicate.swift"

# Xcode Archives 目录
ARCHIVES_DIR="$HOME/Library/Developer/Xcode/Archives"

# 检查参数
if [ $# -eq 0 ]; then
    echo "错误: 请提供 .ips 文件路径"
    echo "用法: analyze_crash.sh <ips_file>"
    exit 1
fi

IPS_FILE="$1"

# 检查 .ips 文件是否存在
if [ ! -f "$IPS_FILE" ]; then
    echo "错误: 文件不存在: $IPS_FILE"
    exit 1
fi

# 检查 Swift 文件是否存在
if [ ! -f "$CONVERT_SCRIPT" ]; then
    echo "错误: 找不到 convertFromJSON.swift 在: $CONVERT_SCRIPT"
    exit 1
fi

if [ ! -f "$SYMBOLICATE_SCRIPT" ]; then
    echo "错误: 找不到 symbolicate.swift 在: $SYMBOLICATE_SCRIPT"
    exit 1
fi

# 获取 .ips 文件的目录和文件名（不含扩展名）
IPS_DIR="$(cd "$(dirname "$IPS_FILE")" && pwd)"
IPS_BASENAME="$(basename "$IPS_FILE" .ips)"

# 生成中间 log 文件名（基于 .ips 文件名）
LOG_FILE="$IPS_DIR/${IPS_BASENAME}.log"

echo "=========================================="
echo "开始分析 crash 文件"
echo "=========================================="
echo "输入文件: $IPS_FILE"
echo "中间文件: $LOG_FILE"
echo "工作目录: $IPS_DIR"
echo ""

# 函数：从 .ips 文件提取应用信息
extract_app_info() {
    local ips_file="$1"
    # 读取第一行 JSON
    local first_line=$(head -n 1 "$ips_file" 2>/dev/null)
    
    if [ -z "$first_line" ]; then
        return 1
    fi
    
    # 使用 Python 或 plutil 解析 JSON（优先使用 Python，因为更可靠）
    if command -v python3 &> /dev/null; then
        BUNDLE_ID=$(echo "$first_line" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('bundleID', ''))" 2>/dev/null)
        BUILD_VERSION=$(echo "$first_line" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('build_version', ''))" 2>/dev/null)
        APP_NAME=$(echo "$first_line" | python3 -c "import sys, json; data = json.load(sys.stdin); print(data.get('app_name', ''))" 2>/dev/null)
    elif command -v python &> /dev/null; then
        BUNDLE_ID=$(echo "$first_line" | python -c "import sys, json; data = json.load(sys.stdin); print(data.get('bundleID', ''))" 2>/dev/null)
        BUILD_VERSION=$(echo "$first_line" | python -c "import sys, json; data = json.load(sys.stdin); print(data.get('build_version', ''))" 2>/dev/null)
        APP_NAME=$(echo "$first_line" | python -c "import sys, json; data = json.load(sys.stdin); print(data.get('app_name', ''))" 2>/dev/null)
    else
        # 如果没有 Python，尝试使用 grep 和 sed（不太可靠但可以工作）
        BUNDLE_ID=$(echo "$first_line" | grep -o '"bundleID":"[^"]*"' | sed 's/"bundleID":"\(.*\)"/\1/')
        BUILD_VERSION=$(echo "$first_line" | grep -o '"build_version":"[^"]*"' | sed 's/"build_version":"\(.*\)"/\1/')
        APP_NAME=$(echo "$first_line" | grep -o '"app_name":"[^"]*"' | sed 's/"app_name":"\(.*\)"/\1/')
    fi
    
    if [ -z "$BUNDLE_ID" ]; then
        return 1
    fi
    
    return 0
}

# 全局变量存储匹配的 archive
MATCHED_ARCHIVE_PATH=""

# 函数：查找匹配的 .xcarchive 文件
find_matching_archive() {
    local bundle_id="$1"
    local build_version="$2"
    local app_name="$3"
    
    MATCHED_ARCHIVE_PATH=""  # 重置
    
    echo "正在搜索匹配的 Archive..."
    echo "  Bundle ID: $bundle_id"
    echo "  Build Version: $build_version"
    echo "  App Name: $app_name"
    echo ""
    
    # 查找所有 .xcarchive 文件
    local archives=()
    while IFS= read -r -d '' archive; do
        archives+=("$archive")
    done < <(find "$ARCHIVES_DIR" -name "*.xcarchive" -type d -print0 2>/dev/null)
    
    if [ ${#archives[@]} -eq 0 ]; then
        echo "警告: 在 $ARCHIVES_DIR 中未找到任何 .xcarchive 文件"
        return 1
    fi
    
    echo "找到 ${#archives[@]} 个 Archive 文件，正在匹配..."
    
    # 遍历每个 archive，查找匹配的（按时间倒序，最新的在前）
    # 使用 find 按修改时间排序（最新的在前），然后转换为数组
    local sorted_archives=()
    while IFS= read -r archive; do
        [ -n "$archive" ] && sorted_archives+=("$archive")
    done < <(find "$ARCHIVES_DIR" -name "*.xcarchive" -type d -print0 2>/dev/null | xargs -0 ls -dt 2>/dev/null)
    
    # 如果排序失败，使用原始数组
    if [ ${#sorted_archives[@]} -eq 0 ]; then
        sorted_archives=("${archives[@]}")
    fi
    
    # 遍历每个 archive，查找匹配的
    for archive in "${sorted_archives[@]}"; do
        
        local products_dir="$archive/Products"
        if [ ! -d "$products_dir" ]; then
            continue
        fi
        
        # 查找所有 .app 文件
        while IFS= read -r -d '' app_path; do
            local app_info_plist="$app_path/Info.plist"
            if [ ! -f "$app_info_plist" ]; then
                continue
            fi
            
            local app_bundle_id=""
            local app_build_version=""
            
            if command -v plutil &> /dev/null; then
                app_bundle_id=$(plutil -extract CFBundleIdentifier raw "$app_info_plist" 2>/dev/null)
                app_build_version=$(plutil -extract CFBundleVersion raw "$app_info_plist" 2>/dev/null)
            else
                app_bundle_id=$(defaults read "$app_info_plist" CFBundleIdentifier 2>/dev/null)
                app_build_version=$(defaults read "$app_info_plist" CFBundleVersion 2>/dev/null)
            fi
            
            if [ -z "$app_bundle_id" ]; then
                continue
            fi
            
            # 精确匹配：Bundle ID 和 Build Version
            if [ "$app_bundle_id" == "$bundle_id" ] && [ "$app_build_version" == "$build_version" ]; then
                echo "✓ 找到精确匹配的 Archive: $(basename "$archive")"
                MATCHED_ARCHIVE_PATH="$archive"
                return 0
            fi
        done < <(find "$products_dir" -name "*.app" -type d -print0 2>/dev/null)
    done
    
    echo "警告: 未找到精确匹配的 Archive (Bundle ID: $bundle_id, Build Version: $build_version)"
    echo "提示: 尝试只匹配 Bundle ID，使用最新的 Archive..."
    
    # 如果精确匹配失败，尝试只匹配 Bundle ID，使用最新的
    for archive in "${sorted_archives[@]}"; do
        
        local products_dir="$archive/Products"
        if [ ! -d "$products_dir" ]; then
            continue
        fi
        
        while IFS= read -r -d '' app_path; do
            local app_info_plist="$app_path/Info.plist"
            if [ ! -f "$app_info_plist" ]; then
                continue
            fi
            
            local app_bundle_id=""
            if command -v plutil &> /dev/null; then
                app_bundle_id=$(plutil -extract CFBundleIdentifier raw "$app_info_plist" 2>/dev/null)
            else
                app_bundle_id=$(defaults read "$app_info_plist" CFBundleIdentifier 2>/dev/null)
            fi
            
            if [ "$app_bundle_id" == "$bundle_id" ]; then
                echo "✓ 找到匹配 Bundle ID 的 Archive (使用最新): $(basename "$archive")"
                MATCHED_ARCHIVE_PATH="$archive"
                return 0
            fi
        done < <(find "$products_dir" -name "*.app" -type d -print0 2>/dev/null)
    done
    
    return 1
}

# 函数：复制 dSYM 文件
copy_dsyms() {
    local archive_path="$1"
    local target_dir="$2"
    
    local dsyms_dir="$archive_path/dSYMs"
    
    if [ ! -d "$dsyms_dir" ]; then
        echo "警告: Archive 中没有 dSYMs 目录: $dsyms_dir"
        return 1
    fi
    
    local dsym_count=0
    while IFS= read -r -d '' dsym; do
        local dsym_name=$(basename "$dsym")
        local target_path="$target_dir/$dsym_name"
        
        if [ -d "$target_path" ]; then
            echo "  - $dsym_name (已存在，跳过)"
        else
            echo "  - 复制 $dsym_name..."
            cp -R "$dsym" "$target_path" 2>/dev/null
            if [ $? -eq 0 ]; then
                ((dsym_count++))
                echo "    ✓ 复制成功"
            else
                echo "    ✗ 复制失败"
            fi
        fi
    done < <(find "$dsyms_dir" -name "*.dSYM" -type d -print0 2>/dev/null)
    
    if [ $dsym_count -gt 0 ]; then
        echo ""
        echo "✓ 成功复制 $dsym_count 个 dSYM 文件到 $target_dir"
        return 0
    else
        echo "警告: 没有复制任何 dSYM 文件"
        return 1
    fi
}

# 步骤 0: 自动查找并复制 dSYM 文件
echo "步骤 0/3: 自动查找并复制 dSYM 文件..."
echo ""

# 提取应用信息
if extract_app_info "$IPS_FILE"; then
    # 查找匹配的 archive
    if find_matching_archive "$BUNDLE_ID" "$BUILD_VERSION" "$APP_NAME"; then
        if [ -n "$MATCHED_ARCHIVE_PATH" ]; then
            echo ""
            copy_dsyms "$MATCHED_ARCHIVE_PATH" "$IPS_DIR"
            echo ""
        else
            echo "警告: 无法自动找到匹配的 Archive，请手动复制 dSYM 文件到: $IPS_DIR"
            echo ""
        fi
    else
        echo "警告: 无法自动找到匹配的 Archive，请手动复制 dSYM 文件到: $IPS_DIR"
        echo ""
    fi
else
    echo "警告: 无法从 .ips 文件提取应用信息，跳过自动查找 dSYM"
    echo "提示: 请手动复制 dSYM 文件到: $IPS_DIR"
    echo ""
fi

# 切换到 .ips 文件所在目录
cd "$IPS_DIR"

# 第一步: 转换 .ips 为 .log
echo "步骤 1/3: 转换 .ips 文件为 .log 格式..."
swift "$CONVERT_SCRIPT" -i "$(basename "$IPS_FILE")" -o "$(basename "$LOG_FILE")"

if [ $? -ne 0 ]; then
    echo "错误: 转换失败"
    exit 1
fi

echo ""
echo "步骤 2/3: 符号化 crash log..."
swift "$SYMBOLICATE_SCRIPT" -crash "$(basename "$LOG_FILE")"

if [ $? -ne 0 ]; then
    echo "错误: 符号化失败"
    exit 1
fi

echo ""
echo "=========================================="
echo "分析完成！"
echo "中间文件保存在: $LOG_FILE"
echo "=========================================="

