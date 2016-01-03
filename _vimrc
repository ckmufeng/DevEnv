" Vundle{{{
"""""""""""""""""""""""""""""""""""Vundle setting""""""""""""""""""
set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#begin()

Bundle 'gmarik/vundle.vim'
Bundle 'easymotion/vim-easymotion'
Plugin 'Lokaltog/vim-powerline'
"Plugin 'https://github.com/Lokaltog/vim-powerline.git'
Plugin 'vimwiki/vimwiki'
Plugin 'altercation/vim-colors-solarized'
Plugin 'vim-scripts/taglist.vim'
Plugin 'vim-scripts/AutoComplPop'
Plugin 'vim-scripts/Align'

call vundle#end()

filetype plugin indent on
" }}}

set nocompatible

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

let mapleader = "-"
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>:nohl<cr>
nnoremap <leader>8  *

"""""""""""""""""""""""""""""""set colorscheme"""""""""""""""""""""""""""""""""""""""""""
syntax enable
set background=dark
colorscheme solarized
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"设置编码自动识别，中文信号显示
set fileencodings=utf-8,gbk
set ambiwidth=double

"设置折叠代码
set fdm=marker
set foldmarker={{{,}}}

"空格table设置
set smartindent
set smarttab
set backspace=2
set nowrap
set tabstop=4
set softtabstop=4
set expandtab

set shiftwidth=2

"启用鼠标
set mouse=a

"启用行号
set nu

"高亮显示匹配的括号
set showmatch

"不要备份文件
set nobackup
set nowb
set hidden
filetype plugin indent on
if exists("&autoread")
	set autoread
endif

"自动补全 Ctrl+n
set completeopt=longest,menu
"自动补全命令时使用菜单式匹配列表
set wildmenu
autocmd FileType ruby,eruby set omnifunc=rubycomplete#Complete
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType java set omnifunc=javacomplete#Complete

"Taglist
let Tlist_Show_One_File=1
let Tlist_Exit_OnlyWindow=1

"cscope shou in quickfix
set cscopequickfix=s-,c-,d-,i-,t-,e-
set autochdir

"WinManager wm
let g:vinManagerWindowLayout='FileExplorer|TagList'
nmap wm:WMToggle <cr>

"MiniBufExplorer {{{
let g:miniBufExplMapWindowNavVim=1
let g:miniBufExplMapWindowNavArrows=1
let g:miniBufExplMapCTabSwitchBufs=1
let g:miniBufExplModeSelTarget=1
"}}}

"窗口管理
set tags=tags

"自动改变当前工作路径
set autochdir

inoremap jk <Esc>:w<CR>
if has("win32")
unmap <C-V>
unmap <C-A>
endif

" inoremap <esc> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>

iabbrev always always@(posedge clk)<CR>begin<CR>end<Esc>jkkA
iabbrev alays always@(posedge clk)<CR>begin<CR>end<Esc>jkkA
iabbrev alwys always@(posedge clk)<CR>begin<CR>end<Esc>jkkA
iabbrev alwyas always@(posedge clk)<CR>begin<CR>end<Esc>jkkA
iabbrev alwsy always@(posedge clk)<CR>begin<CR>end<Esc>jkkA
iabbrev begin begin<CR>end<Esc>jkkA
" iabbrev ( (  )<Esc>ji
set textwidth=200
" set lines=61
" set columns=100
" nnoremap <C-C> i/<Esc>50a*<Esc>a/<Esc>26hi<Tab><Tab><Tab><Esc>4hi

"autocmd BufWritePre *.v :call ChangeTime()


set ff=unix

augroup ftgroup
    autocmd!
    autocmd BufEnter *.v :set ft=verilog
    autocmd BufEnter *.vim :set ft=vim
    autocmd BufEnter *.sh :set ft=sh
    autocmd BufEnter *.cpp :set ft=cpp
augroup END



if has("win32")
"Grep{{{
    let Grep_Path = '"D:\Program Files (x86)\GnuWin32\bin\grep.exe"'
    let Grep_Find_Path = '"D:\Program Files (x86)\GnuWin32\bin\find.exe"'
    let Grep_Xargs_Path = '"D:\Program Files (x86)\GnuWin32\bin\xargs.exe"'
"}}}
"
endif

set cursorline
hi! CursorLine cterm=NONE ctermfg=black ctermbg=green

"""""""""""""""""""""""""""  AutoComplPop"""""""""""""""""""""""""""""
"AutoComplPop{{{
    let g:acp_ignorecaseOption = 0
"}}}

