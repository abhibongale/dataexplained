" User Interface Options
set number " set number line 
syntax on " syntax highlighting displays the source code in different colors
set titlestring=%t " to specify a new title for your Vim window
set title " the command to set this new title
set ruler " to display the cursor’s current position in the Vim
set confirm " the confirm option, the Vim displays the confirmation dialog asking if you want to save the file.
colorscheme torte " set theme
set background=dark " use colors that suit a dark background.
set noerrorbells " Disable beep on errors.
set visualbell " Flash the screen instead of beeping on errors.


" Miscellaneous options
set spell "  enable spell checking
set noswapfile " create no swap file


" Indention Options
set autoindent " New lines inherit the indentation of previous lines.
set shiftwidth=4 " When shifting, indent using four spaces.
set smarttab " Insert “tabstop” number of spaces when the “tab” key is pressed.
set tabstop=4 " Indent using four spaces


" Performance Options
set lazyredraw " Don’t update screen during macro and script execution.


" Search Options
set ignorecase " Ignore case when searching.
set hlsearch " Enable search highlighting.
set smartcase " Automatically switch search to case-sensitive when search query contains an uppercase letter.


" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
" - To install use 'PlugInstall' and to update use 'Plug Update'
call plug#begin('~/.vim/plugged')

" VimTeX is a modern Vim and Neovim filetype and syntax plugin for LaTeX files.
Plug 'lervag/vimtex'
" syntax highlighting and filetype plugins for Markdown
Plug 'tpope/vim-markdown'
" provides automatic closing of quotes, parenthesis, brackets, etc.
Plug 'raimondi/delimitmate'
" A code completion engine 
Plug 'valloric/youcompleteme'
" The NERDTree is a file system explorer for the Vim editor
Plug 'scrooloose/nerdtree'
" A Vim plugin which shows a git diff in the sign column
Plug 'airblade/vim-gitgutter'
call plug#end()

" vim-markdown settings
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'java'] "  enable fenced code block syntax highlighting in your markdown documents

" NERDTree Settings
autocmd VimEnter * NERDTree | wincmd p " Start NERDTree and put the cursor back in the other window.
" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
" Start NERDTree and put the cursor back in the other window.
    \ quit | endif

