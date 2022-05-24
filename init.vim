call plug#begin('~/nvim/plugged')
" below are some vim plugins for demonstration purpose.
" add the plugin you want to use here.
Plug 'iCyMind/NeoSolarized'  
"docs a gauche de l'ecran
Plug 'preservim/nerdtree'

Plug 'pangloss/vim-javascript'

Plug 'prettier/vim-prettier'
"copilot
Plug 'github/copilot.vim'

"affichage au debut de vim avec la vache
Plug 'mhinz/vim-startify'

Plug 'grvcoelho/vim-javascript-snippets'
Plug 'tpope/vim-commentary'
Plug 'preservim/nerdtree'
"theme
Plug 'dracula/vim'
Plug 'honza/vim-snippets'
" Start NERDTree and leave the cursor in it.
autocmd VimEnter * NERDTree | wincmd p
autocmd 
"git plugin for git access
"Plug 'tpope/vim-fugitive'

Plug 'dense-analysis/ale'
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'morhetz/gruvbox'
Plug 'pangloss/vim-javascript'
Plug 'grvcoelho/vim-javascript-snippets'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'kshenoy/vim-signature'
Plug 'junegunn/vim-peekaboo'
" plantuml plugin 
Plug 'aklt/plantuml-syntax'
Plug 'mechatroner/rainbow_csv'
call plug#end()



set mouse=a
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>
"set modifiable on
" set modifiable on 


" Theme Config
colorscheme gruvbox 

set clipboard+=unnamed

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


autocmd FileType plantuml setlocal makeprg=java\ -jar\ plantuml.jar\ ./%\ -o\ /mnt/c/dev

"set foldmethod =marker for js documents

autocmd FileType javascript set foldmethod=marker



