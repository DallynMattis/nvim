call plug#begin('~/.config/nvim/plugged')

" Set <leader> to comma
let mapleader = ","

"below are some vim plugins for demonstration purpose.
"add the plugin you want to use here.
Plug 'iCyMind/NeoSolarized'  
"docs a gauche de l'ecran

Plug 'ryanoasis/vim-devicons'
Plug 'pangloss/vim-javascript'

" post install (yarn install | npm install) then load plugin only for editing supported files
Plug 'prettier/vim-prettier', { 'do': 'yarn install --frozen-lockfile --production' }

"copilot
"Plug 'github/copilot.vim'

"affichage au debut de vim avec la vache
Plug 'mhinz/vim-startify'

Plug 'grvcoelho/vim-javascript-snippets'
Plug 'tpope/vim-commentary'

Plug 'preservim/nerdtree'
let NERDTreeShowHidden=1

Plug 'dracula/vim'


" Start NERDTree and leave the cursor in it.
autocmd VimEnter * NERDTree | wincmd p

"git plugin for git access

Plug 'dense-analysis/ale'
Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'morhetz/gruvbox'
Plug 'pangloss/vim-javascript'
Plug 'grvcoelho/vim-javascript-snippets'
Plug 'kshenoy/vim-signature'
Plug 'junegunn/vim-peekaboo'

" plantuml plugin 
Plug 'aklt/plantuml-syntax'
Plug 'mechatroner/rainbow_csv'
Plug 'matveyt/neoclip'

"git plugin
Plug 'tpope/vim-fugitive'



"scrollbar minimap + config
Plug 'wfxr/minimap.vim'
Plug 'wfxr/code-minimap'


" Set up minimap
" Enable code-minimap
let g:code_minimap_enable = 1
let g:code_minimap_width = 10
let g:minimap_width = 10        " Width of the minimap window
let g:minimap_auto_start = 1    " Automatically start minimap when opening a file
let g:minimap_auto_start_win_enter = 1  " Start minimap when entering a window

" Customize minimap colors (optional)
highlight MinimapCurrentLine ctermfg=NONE ctermbg=NONE cterm=NONE gui=NONE guibg=#666666

" Toggle minimap with a key mapping (optional)
nnoremap <silent> <leader>m :MinimapToggle<CR>

" Customize the minimap's appearance (optional)
let g:minimap_highlight_range = 1
let g:minimap_highlight_search = 1

" Set the minimap to display only specific file types (optional)
let g:minimap_filetypes = ['python', 'javascript', 'typescript']




" airline display
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

"PLUGIN FOR COMPLETION

Plug 'rafi/awesome-vim-colorschemes'
Plug 'ap/vim-css-color'
"aPlug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-unimpaired'

"CoC Settings

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'fannheyward/coc-pyright'

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" configs
nmap <leader>rn <Plug>(coc-rename)

call plug#end()



set mouse=a

"Theme Config
colorscheme gruvbox

let g:NERDTreeShowHidden = 1
set clipboard+=unnamed
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
set nocompatible

"airline Config
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
let g:airline#extensions#tabline#formatter = 'default'
let g:airline_powerline_fonts = 1



" To display spaces and change colors
"
" SpecialKey is the name of group including spaces,
" ctermfg => color terminal  foreground
" to disable : 'set nolist'
set listchars=tab:>-,trail:.,extends:>,precedes:<,space:.,nbsp:!
" list of filetypes for wich we want spaces to be displayed
autocmd FileType vim setlocal list
autocmd FileType yaml setlocal list



" Ale linters 

let g:ale_linters = {
\   'javascript': ['eslint'],
\   'go': ['golangci-lint', 'gofmt']}
autocmd FileType plantuml setlocal makeprg=java\ -jar\ plantuml.jar\ ./%\ -o\ /mnt/c/dev

"set foldmethod =marker for js documents

autocmd FileType javascript set foldmethod=marker



