set nocompatible
" ʹ��Windows ��ص�ϰ���趨
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

" �ж���ǰ����ϵͳ����
if (has("win32") || has("win64") || has("win32unix"))
    let g:isWin = 1
else
    let g:isWin = 0
endif


" ��;��Ϊ����ǰ׺
let mapleader = ";"   
" ��ɫ
colo desert
set guifont=Consolas:h12
set go="�޲˵�,������"
" �к�
set number  
set nu
" history�ļ�����Ҫ��¼������ 
set history=500 
" �ڴ���δ�����ֻ���ļ���ʱ�򣬵���ȷ�� 
set confirm 

" ��windows��������� 
set clipboard+=unnamed 
" ����ļ����� 
filetype on 
" �����ļ����Ͳ�� 
filetype plugin on 
" Ϊ�ض��ļ�����������������ļ� 
filetype indent on

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set fileformats=dos,unix,mac " support all three, in this order
if has("win32")
	set fileencoding=chinese
else
	set fileencoding=utf-8
endif
"����˵�����
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
language messages zh_CN.utf-8

set showcmd         " ��ʾ����
set lz              " �����к�ʱ��������ִ�����֮ǰ�����ػ���Ļ
set hid             " ������û�б����������л�buffer
set magic
set ai              " �Զ�����
set si              " ��������
" ����ȫ�ֱ��� 
set viminfo+=! 

" �������·��ŵĵ��ʲ�Ҫ�����зָ� 
set iskeyword+=_,$,@,%,#,- 

" �﷨���� 
syntax on 

" ��Ҫ�����ļ��������Լ���Ҫȡ�ᣩ 
set nobackup 

" ��Ҫ����swap�ļ�����buffer��������ʱ�������� 
setlocal noswapfile 
set bufhidden=hide 

" ��ǿģʽ�е��������Զ���ɲ��� 
set wildmenu 

" ��״̬������ʾ�������λ�õ��кź��к� 
set ruler 
set rulerformat=%20(%2*%<%f%=\ %m%r\ %3l\ %c\ %p%%%) 

" �����У���״̬���£��ĸ߶ȣ�Ĭ��Ϊ1��������2 
set cmdheight=2 

" ʹ�ظ����backspace����������indent, eol, start�� 
set backspace=2 

" ����backspace�͹�����Խ�б߽� 
set whichwrap+=<,>,h,l 

" ������buffer���κεط�ʹ����꣨����office���ڹ�����˫����궨λ�� 
set mouse=a 
set selection=exclusive 
set selectmode=mouse,key 

" ������ʱ����ʾ�Ǹ�Ԯ���������ͯ����ʾ 
set shortmess=atI 

" ͨ��ʹ��: commands������������ļ�����һ�б��ı�� 
set report=0 

" ����vim��������ĵε��� 
set noerrorbells 

" �ڱ��ָ�Ĵ��ڼ���ʾ�հף������Ķ� 
set fillchars=vert:\ ,stl:\ ,stlnc:\

if (has("gui_running"))
" ͼ�ν����µ�����
    set nowrap
    set guioptions+=b
	set guioptions+=r
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ״̬��
set laststatus=2      " ������ʾ״̬��
highlight StatusLine cterm=bold ctermfg=yellow ctermbg=blue
" ��ȡ��ǰ·������$HOMEת��Ϊ~
function! CurDir()
    let curdir = substitute(getcwd(), $HOME, "~", "g")
    return curdir
endfunction
set statusline=[%n]\ %f%m%r%h\ \|\ \ pwd:\ %{CurDir()}\ \ \|%=\|\ %l,%c\ %p%%\ \|\ ascii=%b,hex=%b%{((&fenc==\"\")?\"\":\"\ \|\ \".&fenc)}\ \|\ %{$USER}\ @\ %{hostname()}\ 


" ;c���ٽ���shell
nmap <silent> <leader>c :shell<cr>
"Fast reloading of the .vimrc
map <silent> <leader>ss :source ~/_vimrc<cr>
"Fast editing of .vimrc
map <silent> <leader>ee :e ~/_vimrc<cr>
"When .vimrc is edited, reload it
autocmd! bufwritepost _vimrc source ~/_vimrc 

" �Զ���ȫ
set ofu=syntaxcomplete#Complete

" ��c-j,k��buffer֮���л�
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

" �ָ��ϴ��ļ���λ��
set viminfo='10,\"100,:20,%,n~/.viminfo
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" ������ƥ�� 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ������ʾƥ������� 
set showmatch 

" ƥ�����Ÿ�����ʱ�䣨��λ��ʮ��֮һ�룩 
set matchtime=5 

" ��������ʱ�����ܴ�Сд(������д�д�ַ�,��ʹ�ô�Сд����,��������) 
set ignorecase smartcase 

" ��������
set hlsearch
" �رո߶�����
nmap <silent><leader>h :silent noh<CR>

" ������ʱ������Ĵʾ�����ַ�����������firefox�������� 
set incsearch 

" ����:set list������Ӧ����ʾЩɶ�� 
set listchars=tab:\|\ ,trail:.,extends:>,precedes:<,eol:$ 

" ����ƶ���buffer�Ķ����͵ײ�ʱ����3�о��� 
set scrolloff=3 

" ��Ҫ��˸ 
set novisualbell 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" �ı���ʽ���Ű� 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" �Զ���ʽ�� 
set formatoptions=tcrqn 

" �̳�ǰһ�е�������ʽ���ر������ڶ���ע�� 
"set autoindent 

" ΪC�����ṩ�Զ����� 
set smartindent 

" ʹ��C��ʽ������ 
set cindent 

" �Ʊ��Ϊ4 
set tabstop=4 

" ͳһ����Ϊ4 
set softtabstop=4 
set shiftwidth=4 

" ��Ҫ�ÿո�����Ʊ�� 
set noexpandtab 

" ��Ҫ���� 
set nowrap 

" ���кͶο�ʼ��ʹ���Ʊ�� 
set smarttab

" �Զ��л�Ŀ¼
set autochdir
autocmd BufEnter * silent! lcd %:p:h:gs/ /\\ /

" �ÿո���������۵� 
set foldenable 
set foldmethod=manual 
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR> 

" �������
" �Զ�������ź�����
inoremap <leader>1 ()<esc>:let leavechar=")"<cr>i
inoremap <leader>2 []<esc>:let leavechar="]"<cr>i
inoremap <leader>3 {}<esc>:let leavechar="}"<cr>i
inoremap <leader>4 {<esc>o}<esc>:let leavechar="}"<cr>O
inoremap <leader>q ''<esc>:let leavechar="'"<cr>i
inoremap <leader>w ""<esc>:let leavechar='"'<cr>i

" ��д
iab idate <c-r>=strftime("%Y-%m-%d")<CR>
iab itime <c-r>=strftime("%H:%M")<CR>
iab igmail haozes@gmail.com
iab iname Haozes

" �������
au GUIENTER * simalt ~x

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" CTags���趨 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""" 
" ������������
nmap <silent> <leader>t :TlistToggle<cr> 
let Tlist_Sort_Type = "name" 
" ���Ҳ���ʾ���� 
let Tlist_Use_Right_Window = 1 
" ѹ����ʽ 
let Tlist_Compart_Format = 1 
" ���ֻ��һ��buffer��kill����Ҳkill��buffer 
let Tlist_Exist_OnlyWindow = 1 
" ��Ҫ�ر������ļ���tags 
let Tlist_File_Fold_Auto_Close = 0
" ��Ҫ��ʾ�۵��� 
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
let OmniCpp_DefaultNamespaces = ["std"]     " ���ŷָ���ַ���
let OmniCpp_MayCompleteScope = 1 
let OmniCpp_ShowPrototypeInAbbr = 0 
let OmniCpp_SelectFirstItem = 2 
" c-j�Զ���ȫ������ȫ�˵���ʱ��c-j,k����ѡ��
imap <expr> <c-j>      pumvisible()?"\<C-N>":"\<C-X><C-O>"
imap <expr> <c-k>      pumvisible()?"\<C-P>":"\<esc>"
" f:�ļ�����ȫ��l:�в�ȫ��d:�ֵ䲹ȫ��]:tag��ȫ
imap <C-]>             <C-X><C-]>
imap <C-F>             <C-X><C-F>
imap <C-D>             <C-X><C-D>
imap <C-L>             <C-X><C-L> 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" NERD_commenter.vim
" http://www.vim.org/scripts/script.php?script_id=1218
" Toggle����ע��/���ԸС�ע��/ע�͵���β/ȡ��ע��
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
"Buffers Explorer ����Ҫgenutils.vim
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

" F3 ���ļ��в���
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
" python ������
" map <F5> :!python.exe %
" let g:pydiction_location='$VIMRUNTIME\ftplugin\pydiction\complete-dict'

" F5���������C����F6���������C++���� 
" ��ע�⣬����������windows��ʹ�ûᱨ�� 
" ��Ҫȥ��./�������ַ� 

" C�ı�������� 
"map <F5> :call CompileRunGcc()<CR> 
"func! CompileRunGcc() 
"exec "w" 
"exec "!gcc % -o %<" 
"exec "! %<" 
"endfunc 

" C++�ı�������� 
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
