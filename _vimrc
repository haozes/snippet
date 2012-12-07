set nocompatible
" 使用Windows 相关的习惯设定
source $VIMRUNTIME/mswin.vim
behave mswin

set diffexpr=MyDiff()
function! MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"my custum config

" 判定当前操作系统类型
if (has("win32") || has("win64") || has("win32unix"))
    let g:isWin = 1
else
    let g:isWin = 0
endif


" 用;作为命令前缀
let mapleader = ";"   
" 配色
colo desert
set guifont=Consolas:h12
set go="无菜单,工具栏"
" 行号
set number  
set nu
" history文件中需要记录的行数 
set history=500 
" 在处理未保存或只读文件的时候，弹出确认 
set confirm 

" 与windows共享剪贴板 
set clipboard+=unnamed 
" 侦测文件类型 
filetype on 
" 载入文件类型插件 
filetype plugin on 
" 为特定文件类型载入相关缩进文件 
filetype indent on

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set fileformats=dos,unix,mac " support all three, in this order
if has("win32")
	set fileencoding=chinese
else
	set fileencoding=utf-8
endif
"解决菜单乱码
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
language messages zh_CN.utf-8

set showcmd         " 显示命令
set lz              " 当运行宏时，在命令执行完成之前，不重绘屏幕
set hid             " 可以在没有保存的情况下切换buffer
set magic
set ai              " 自动缩进
set si              " 智能缩进
" 保存全局变量 
set viminfo+=! 

" 带有如下符号的单词不要被换行分割 
set iskeyword+=_,$,@,%,#,- 

" 语法高亮 
syntax on 

" 不要备份文件（根据自己需要取舍） 
set nobackup 

" 不要生成swap文件，当buffer被丢弃的时候隐藏它 
setlocal noswapfile 
set bufhidden=hide 

" 增强模式中的命令行自动完成操作 
set wildmenu 

" 在状态行上显示光标所在位置的行号和列号 
set ruler 
set rulerformat=%20(%2*%<%f%=\ %m%r\ %3l\ %c\ %p%%%) 

" 命令行（在状态行下）的高度，默认为1，这里是2 
set cmdheight=2 

" 使回格键（backspace）正常处理indent, eol, start等 
set backspace=2 

" 允许backspace和光标键跨越行边界 
set whichwrap+=<,>,h,l 

" 可以在buffer的任何地方使用鼠标（类似office中在工作区双击鼠标定位） 
set mouse=a 
set selection=exclusive 
set selectmode=mouse,key 

" 启动的时候不显示那个援助索马里儿童的提示 
set shortmess=atI 

" 通过使用: commands命令，告诉我们文件的哪一行被改变过 
set report=0 

" 不让vim发出讨厌的滴滴声 
set noerrorbells 

" 在被分割的窗口间显示空白，便于阅读 
set fillchars=vert:\ ,stl:\ ,stlnc:\

if (has("gui_running"))
" 图形界面下的设置
    set nowrap
    set guioptions+=b
	set guioptions+=r
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 状态栏
set laststatus=2      " 总是显示状态栏
highlight StatusLine cterm=bold ctermfg=yellow ctermbg=blue
" 获取当前路径，将$HOME转化为~
function! CurDir()
    let curdir = substitute(getcwd(), $HOME, "~", "g")
    return curdir
endfunction
set statusline=[%n]\ %f%m%r%h\ \|\ \ pwd:\ %{CurDir()}\ \ \|%=\|\ %l,%c\ %p%%\ \|\ ascii=%b,hex=%b%{((&fenc==\"\")?\"\":\"\ \|\ \".&fenc)}\ \|\ %{$USER}\ @\ %{hostname()}\ 


" ;c快速进入shell
nmap <silent> <leader>c :shell<cr>
"Fast reloading of the .vimrc
map <silent> <leader>ss :source ~/_vimrc<cr>
"Fast editing of .vimrc
map <silent> <leader>ee :e ~/_vimrc<cr>
"When .vimrc is edited, reload it
autocmd! bufwritepost _vimrc source ~/_vimrc 

" 自动补全
set ofu=syntaxcomplete#Complete

" 用c-j,k在buffer之间切换
nn <C-J> :bn<cr>
nn <C-K> :bp<cr>

" tab navigation like firefox
:nmap <C-S-tab> :tabprevious<CR>
:nmap <C-tab> :tabnext<CR>
:map <C-S-tab> :tabprevious<CR>
:map <C-tab> :tabnext<CR>
:imap <C-S-tab> <Esc>:tabprevious<CR>i
:imap <C-tab> <Esc>:tabnext<CR>i
:nmap <C-t> :tabnew<CR>
:imap <C-t> <Esc>:tabnew<CR>
map <S-w> :tabclose<CR>
map <S-c> :set nu<CR>
map <S-x> <C-w><C-w>

" 恢复上次文件打开位置
set viminfo='10,\"100,:20,%,n~/.viminfo
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" 搜索和匹配 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 高亮显示匹配的括号 
set showmatch 

" 匹配括号高亮的时间（单位是十分之一秒） 
set matchtime=5 

" 在搜索的时候智能大小写(如果输有大写字符,作使用大小写敏感,否则不敏感) 
set ignorecase smartcase 

" 高亮搜索
set hlsearch
" 关闭高度搜索
nmap <silent><leader>h :silent noh<CR>

" 在搜索时，输入的词句的逐字符高亮（类似firefox的搜索） 
set incsearch 

" 输入:set list命令是应该显示些啥？ 
set listchars=tab:\|\ ,trail:.,extends:>,precedes:<,eol:$ 

" 光标移动到buffer的顶部和底部时保持3行距离 
set scrolloff=3 

" 不要闪烁 
set novisualbell 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 文本格式和排版 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" 自动格式化 
set formatoptions=tcrqn 

" 继承前一行的缩进方式，特别适用于多行注释 
"set autoindent 

" 为C程序提供自动缩进 
set smartindent 

" 使用C样式的缩进 
set cindent 

" 制表符为4 
set tabstop=4 

" 统一缩进为4 
set softtabstop=4 
set shiftwidth=4 

" 不要用空格代替制表符 
set noexpandtab 

" 不要换行 
set nowrap 

" 在行和段开始处使用制表符 
set smarttab

" 自动切换目录
set autochdir
autocmd BufEnter * silent! lcd %:p:h:gs/ /\\ /

" 用空格键来开关折叠 
set foldenable 
set foldmethod=manual 
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR> 

" 快捷输入
" 自动完成括号和引号
inoremap <leader>1 ()<esc>:let leavechar=")"<cr>i
inoremap <leader>2 []<esc>:let leavechar="]"<cr>i
inoremap <leader>3 {}<esc>:let leavechar="}"<cr>i
inoremap <leader>4 {<esc>o}<esc>:let leavechar="}"<cr>O
inoremap <leader>q ''<esc>:let leavechar="'"<cr>i
inoremap <leader>w ""<esc>:let leavechar='"'<cr>i

" 缩写
iab idate <c-r>=strftime("%Y-%m-%d")<CR>
iab itime <c-r>=strftime("%H:%M")<CR>
iab igmail haozes@gmail.com
iab iname Haozes

" 启动最大化
au GUIENTER * simalt ~x

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" CTags的设定 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" 按照名称排序
nmap <silent> <leader>t :TlistToggle<cr> 
let Tlist_Sort_Type = "name" 
" 在右侧显示窗口 
let Tlist_Use_Right_Window = 1 
" 压缩方式 
let Tlist_Compart_Format = 1 
" 如果只有一个buffer，kill窗口也kill掉buffer 
let Tlist_Exist_OnlyWindow = 1 
" 不要关闭其他文件的tags 
let Tlist_File_Fold_Auto_Close = 0
" 不要显示折叠树 
let Tlist_Enable_Fold_Column = 0 

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" winManager 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
let g:winManagerWindowLayout='FileExplorer|TagList' 
nmap wm :WMToggle<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" OmniCppComplete.vim
" http://www.vim.org/scripts/script.php?script_id=1520
set completeopt=menu
let OmniCpp_ShowPrototypeInAbbr = 1 
let OmniCpp_DefaultNamespaces = ["std"]     " 逗号分割的字符串
let OmniCpp_MayCompleteScope = 1 
let OmniCpp_ShowPrototypeInAbbr = 0 
let OmniCpp_SelectFirstItem = 2 
" c-j自动补全，当补全菜单打开时，c-j,k上下选择
imap <expr> <c-j>      pumvisible()?"\<C-N>":"\<C-X><C-O>"
imap <expr> <c-k>      pumvisible()?"\<C-P>":"\<esc>"
" f:文件名补全，l:行补全，d:字典补全，]:tag补全
imap <C-]>             <C-X><C-]>
imap <C-F>             <C-X><C-F>
imap <C-D>             <C-X><C-D>
imap <C-L>             <C-X><C-L> 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERD_commenter.vim
" http://www.vim.org/scripts/script.php?script_id=1218
" Toggle单行注释/“性感”注释/注释到行尾/取消注释
map <leader>cc ,c<space>
map <leader>cs ,cs
map <leader>c$ ,c$
map <leader>cu ,cu


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERDTree
let NERDTreeShowHidden = 1
let NERDTreeWinPos = "left"
"let NERDTreeWinSize = 30 
nmap <leader>n :NERDTreeToggle<cr>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Buffers Explorer （需要genutils.vim
" http://vim.sourceforge.net/scripts/script.php?script_id=42
" http://www.vim.org/scripts/script.php?script_id=197
let g:bufExplorerDefaultHelp=0       " Do not show default help.
let g:bufExplorerShowRelativePath=1  " Show relative paths.
let g:bufExplorerSortBy='mru'        " Sort by most recently used.
let g:bufExplorerSplitRight=0        " Split left.
let g:bufExplorerSplitVertical=1     " Split vertically.
let g:bufExplorerSplitVertSize = 30  " Split width
let g:bufExplorerUseCurrentWindow=1  " Open in new window.
autocmd BufWinEnter \[Buf\ List\] setl nonumber
nmap <silent> <Leader>b :BufExplorer<CR>

" F3 在文件中查找
nnoremap <F3> :vimgrep <cword> *.

"quickfix 
nmap <F6> :cn<cr>
nmap <S-F6> :cp<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"showmarks setting
" http://easwy.com/blog/archives/advanced-vim-skills-advanced-move-method/
" Enable ShowMarks
let showmarks_enable = 1
" Show which marks
let showmarks_include = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
" Ignore help, quickfix, non-modifiable buffers
let showmarks_ignore_type = "hqm"
" Hilight lower & upper marks
let showmarks_hlline_lower = 1
let showmarks_hlline_upper = 1

" markbrowser setting
nmap <silent> <leader>mk :MarksBrowser<cr> 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"zencoding setting
"http://www.vim.org/scripts/script.php?script_id=2981
"for other editor :http://code.google.com/p/zen-coding/
let g:user_zen_expandabbr_key = '<c-e>'
let g:use_zen_complete_tag = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" python 的运行
" map <F5> :!python.exe %
" let g:pydiction_location='$VIMRUNTIME\ftplugin\pydiction\complete-dict'

" F5编译和运行C程序，F6编译和运行C++程序 
" 请注意，下述代码在windows下使用会报错 
" 需要去掉./这两个字符 

" C的编译和运行 
"map <F5> :call CompileRunGcc()<CR> 
"func! CompileRunGcc() 
"exec "w" 
"exec "!gcc % -o %<" 
"exec "! %<" 
"endfunc 

" C++的编译和运行 
" map <F6> :call CompileRunGpp()<CR> 
" func! CompileRunGpp() 
" exec "w" 
" vexec "!g++ % -o %<" 
" exec "! %<" 
" endfunc 

" ctag cope setting

set completeopt=menu
map <F11> :call Update_CsTag()<CR>
map <F12> :call Do_CsTag()<CR>
nmap <C-@>s :cs find s <C-R>=expand("<cword>")<CR><CR>:copen<CR>
nmap <C-@>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-@>c :cs find c <C-R>=expand("<cword>")<CR><CR>:copen<CR>
nmap <C-@>t :cs find t <C-R>=expand("<cword>")<CR><CR>:copen<CR>
nmap <C-@>e :cs find e <C-R>=expand("<cword>")<CR><CR>:copen<CR>
nmap <C-@>f :cs find f <C-R>=expand("<cfile>")<CR><CR>:copen<CR>
nmap <C-@>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>:copen<CR>
nmap <C-@>d :cs find d <C-R>=expand("<cword>")<CR><CR>:copen<CR>
function! Update_CsTag()
    if has("cscope")
        silent! execute "!ctags -r"
    endif
endfunction

function! Do_CsTag()
    let dir = getcwd()
    if filereadable("tags")
        if(g:isWin==1)
            let tagsdeleted=delete(dir."\\"."tags")
        else
            let tagsdeleted=delete("./"."tags")
        endif
        if(tagsdeleted!=0)
            echohl WarningMsg | echo "Fail to do tags! I cannot delete the tags" | echohl None
            return
        endif
    endif
    if has("cscope")
        silent! execute "cs kill -1"
    endif
    if filereadable("cscope.files")
        if(g:isWin==1)
            let csfilesdeleted=delete(dir."\\"."cscope.files")
        else
            let csfilesdeleted=delete("./"."cscope.files")
        endif
        if(csfilesdeleted!=0)
            echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.files" | echohl None
            return
        endif
    endif
    if filereadable("cscope.out")
        if(g:isWin==1)
            let csoutdeleted=delete(dir."\\"."cscope.out")
        else
            let csoutdeleted=delete("./"."cscope.out")
        endif
        if(csoutdeleted!=0)
            echohl WarningMsg | echo "Fail to do cscope! I cannot delete the cscope.out" | echohl None
            return
        endif
    endif
    if(executable('ctags'))
        "silent! execute "!ctags -R --c-types=+p --fields=+S *"
        silent! execute "!ctags -R --c++-kinds=+p --fields=+iaS --extra=+q ."
    endif
    if(executable('cscope') && has("cscope") )
        if(g:isWin!=1)
            silent! execute "!find . -name '*.h' -o -name '*.c' -o -name '*.cpp' -o -name '*.java' -o -name '*.cs' > cscope.files"
        else
            silent! execute "!dir /s/b *.c,*.cpp,*.h,*.java,*.cs >> cscope.files"
        endif
        silent! execute "!cscope -b"
        execute "normal :"
        if filereadable("cscope.out")
            execute "cs add cscope.out"
        endif
    endif
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""custom config
