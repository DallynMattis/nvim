call plug#begin('~/nvim/plugged')
" below are some vim plugins for demonstration purpose.
" add the plugin you want to use here.
Plug 'iCyMind/NeoSolarized'  
Plug 'preservim/nerdtree'
Plug 'pangloss/vim-javascript'
Plug 'prettier/vim-prettier'
Plug 'github/copilot.vim'
Plug 'mhinz/vim-startify'
Plug 'grvcoelho/vim-javascript-snippets'
Plug 'tpope/vim-commentary'
Plug 'preservim/nerdtree'
Plug 'dracula/vim'
Plug 'honza/vim-snippets'
" Start NERDTree and leave the cursor in it.
autocmd VimEnter * NERDTree | wincmd p
autocmd 


Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'morhetz/gruvbox'
Plug 'pangloss/vim-javascript'
Plug 'grvcoelho/vim-javascript-snippets'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'mechatroner/rainbow_csv'
call plug#end()



set mouse=a
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>
"set modifiable on
" set modifiable on 


" Theme Config
colorscheme gruvbox 


"set number
set numberwidth=4

set showmatch

set tabstop=4 softtabstop=2 shiftwidth=4
filetype plugin indent on
set foldlevelstart=10
set clipboard+=unnamedplus
set signcolumn=number
set encoding=UTF-8
set updatetime=300
set foldnestmax=40
set tabpagemax=10
set laststatus=2
set foldcolumn=2
set scrolloff=8
set foldenable
set noshowmode
set expandtab
set linebreak
set wildmenu
set nobackup
set undofile
set nowrap
set hidden
set number
syntax on
set ruler
set title

"set foldmethod =marker for js documents

if(&filetype=='javascript')
    set foldmethod=marker





