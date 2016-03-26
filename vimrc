""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"   Filename: .vimrc                                                         "
" Maintainer: Ibrahim Ahmed <abeahmed2@gmail.com>                            "
"        URL: http://github.com/atbe/dotfiles                                "
"                                                                            "
"                                                                            "
" Sections:                                                                  "
"   01. General ................. General Vim behavior                       "
"   02. Vundle/Pathogen .................. Setup Vundle&Pathogen             "
"   03. Plugin Mods ............. Modifications made to plugins              "
"   04. Keymapping ............. All the different key mappings              " 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 01. General                                                                "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible              " be iMproved, required
filetype off                  " required
set number	        	        " Set line numbers on by default.
syntax on		                  " Set Syntax on by default.
set t_Co=256                  " Make the colors purty.
set ls=2		                  " Show full file path always
set tabstop=2 softtabstop=2 shiftwidth=2 noexpandtab
set mouse=a                   " Turn that mouse on
set shell=/bin/bash

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 02. Vundle and Pathogen                                                    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Pathogen first because it is a really short setup lol
runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

Plugin 'VundleVim/Vundle.vim'
" Vundle Packages: "
" Fugitive
Plugin 'tpope/vim-fugitive'
" NERDTree
Plugin 'scrooloose/nerdTree'
" vim-airline
Plugin 'bling/vim-airline'
" vim-airline-themes
Plugin 'vim-airline/vim-airline-themes'
" YCM
Plugin 'valloric/youcompleteme'
" indentline
Plugin 'yggdroot/indentline'
" The NERD Commenter
Plugin 'scrooloose/nerdcommenter'
" Vim colorschemes
Plugin 'flazz/vim-colorschemes'
call vundle#end()            " required
filetype plugin indent on    " required

" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 03. Plugin Mods                                                            "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" airline
let g:airline_theme='molokai'       " Set theme to JellyBeans
set laststatus=2                       " Always show status bar
" YCM
let g:ycm_global_ycm_extra_conf = "~/.vim/bundle/youcompleteme/third_party/ycmd/cpp/ycm/.ycm_extra_conf.py"

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 04. Keymapping                                                             "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab Managment Settings
nnoremap th  :tabfirst<CR>
nnoremap tk  :tabnext<CR>
nnoremap tj  :tabprev<CR>
nnoremap tl  :tablast<CR>
nnoremap tt  :tabedit<Space>
nnoremap tn  :tabnew<Space>
nnoremap tm  :tabm<Space>
nnoremap td  :tabclose<CR>
