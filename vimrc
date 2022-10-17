""""" added by mkgilbert env_setup repo """""
"""""""""""""""""""""""""""""""""""""""""""""
" Vundle Stuff
"""""""""""""""""""""""""""""""""""""""""""""
set nocompatible	" required
filetype off		" required

" runtime path
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle managme Vundle, required
Plugin 'gmarik/Vundle.vim'

"""""""" add plugins here """"""""
"Plugin 'jnurmine/Zenburn'
"Plugin 'altercation/vim-colors-solarized'
Plugin 'lifepillar/vim-solarized8'
Plugin 'tmhedberg/SimpylFold'
Plugin 'scrooloose/nerdtree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'	" Git from inside Vim
Plugin 'plytophogy/vim-virtualenv'
Plugin 'godlygeek/tabular'
Plugin 'preservim/vim-markdown'

" Python-specific plugins
Plugin 'vim-scripts/indentpython.vim'
"Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-syntastic/syntastic'
Plugin 'nvie/vim-flake8'
""""""""    end plugins   """"""""

call vundle#end()		" required
filetype plugin indent on	" required
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"""""""""""""""""""""""""""""""""""""""""""""
" Vim General Settings
"""""""""""""""""""""""""""""""""""""""""""""
"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Color scheme
syntax enable
"let g:solarized_visibility = "high"
"let g:solarized_contrast = "high"
set termguicolors
"let g:solarized_termcolors=256
set background=dark
colorscheme solarized8
"set t_Co=256
"colors zenburn
" Fix tmux colors - This does *NOT* work!
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

" Enable folding
set foldmethod=indent
set foldlevel=99

" Enable folding with the spacebar
nnoremap <space> za

" Web languages indentation
au BufNewFile,BufRead *.js, *.html, *.css:
    \ set tabstop=2
    \ set softtabstop=2
    \ set shiftwidth=2

" Indentation
set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=120
set expandtab
set autoindent
set fileformat=unix

"""""""""""""""""""""""""""""""""""""""""""""
" Python Settings
"""""""""""""""""""""""""""""""""""""""""""""
" Python Mark extra white space as bad
highlight BadWhitespace ctermbg=red guibg=darkred
au BufRead,BufNewFile *.py,*.pyw,*.c,*.h match BadWhitespace /\s\+$/

" ignore .pyc files in NERDTree
let NERDTreeIgnore=['\.pyc$', '\~$']

" Fix YouCompleteMe stuff
let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>
