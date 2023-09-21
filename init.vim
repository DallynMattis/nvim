call plug#begin('~/.config/nvim/plugged')

" below are some vim plugins for demonstration purpose.
" add the plugin you want to use here.
Plug 'iCyMind/NeoSolarized'  
"docs a gauche de l'ecran

Plug 'pangloss/vim-javascript'

Plug 'prettier/vim-prettier'
"copilot
Plug 'github/copilot.vim'

"affichage au debut de vim avec la vache
Plug 'mhinz/vim-startify'

Plug 'grvcoelho/vim-javascript-snippets'
Plug 'tpope/vim-commentary'
Plug 'preservim/nerdtree'
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

"scrollbar minimap
Plug 'wfxr/minimap.vim',{'do': ':!cargo install --locked code-minimap'}




"PLUGIN FOR COMPLETION

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'fannheyward/coc-pyright'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'ap/vim-css-color'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-unimpaired'

"CoC Settings
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
 
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
 
" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
"Ultisnips Settings
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"
 
" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"
 
"coc-snippets Settings
"inoremap <silent><expr> <TAB>
"      \ coc#pum#visible() ? coc#_select_confirm() :
"      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
"      \ CheckBackspace() ? "\<TAB>" :
"      \ coc#refresh()
"
"function! CheckBackspace() abort
"  let col = col('.') - 1
"  return !col || getline('.')[col - 1]  =~# '\s'
"endfunction
"
"let g:coc_snippet_next = '<tab>'




let g:minimap_width = 10
let g:minimap_auto_sart = 1
let g:minimap_auto_start_win_enter = 1



call plug#end()



set mouse=a
map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>
"set modifiable on
"set modifiable on 


"Theme Config
colorscheme gruvbox 

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


autocmd FileType plantuml setlocal makeprg=java\ -jar\ plantuml.jar\ ./%\ -o\ /mnt/c/dev

"set foldmethod =marker for js documents

autocmd FileType javascript set foldmethod=marker



