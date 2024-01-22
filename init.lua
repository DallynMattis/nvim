--Installer LazyLoad
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require('lazy').setup({
    {'iCyMind/NeoSolarized'},
    {'nvim-treesitter/nvim-treesitter'},
    {'ryanoasis/vim-devicons'},
    {'pangloss/vim-javascript'},
    {'prettier/vim-prettier', run = 'yarn install --frozen-lockfile --production'},
    {'Jremmen/vim-ripgrep'},
    {'mhinz/vim-startify'},
    {'grvcoelho/vim-javascript-snippets'},
    {'tpope/vim-commentary'},
    {'preservim/nerdtree'},
    {'dracula/vim'},
    {'dense-analysis/ale'},
    {'preservim/nerdcommenter'},
    {'tpope/vim-surround'},
    {'morhetz/gruvbox'},
    {'pangloss/vim-javascript'},
    {'grvcoelho/vim-javascript-snippets'},
    {'kshenoy/vim-signature'},
    {'aklt/plantuml-syntax'},
    {'mechatroner/rainbow_csv'},
    {'matveyt/neoclip'},
    {'tpope/vim-fugitive'},
    --{'wfxr/minimap.vim'},
    --{'wfxr/code-minimap'},
    {'vim-airline/vim-airline'},
    {'vim-airline/vim-airline-themes'},
    {'rafi/awesome-vim-colorschemes'},
    {'ap/vim-css-color'},
    {'honza/vim-snippets'},
    {'jiangmiao/auto-pairs'},
    --{'neoclide/coc.nvim'},
    --{'fannheyward/coc-pyright'}
})
--[[] Set up minimap
vim.g.code_minimap_enable = 1
vim.g.code_minimap_width = 10
vim.g.minimap_width = 10
vim.g.minimap_auto_start = 1
vim.g.minimap_auto_start_win_enter = 1
vim.cmd('highlight MinimapCurrentLine ctermfg=NONE ctermbg=NONE cterm=NONE gui=NONE guibg=#666666')
vim.api.nvim_set_keymap('n', '<leader>m', ':MinimapToggle<CR>', { noremap = true, silent = true })
vim.g.minimap_highlight_range = 1
vim.g.minimap_highlight_search = 1
vim.g.minimap_filetypes = {'python', 'javascript', 'typescript'}
]]


--Airline display configuration
vim.g.airline_extensions_tabline_enabled = 1
vim.g.airline_extensions_tabline_left_sep = ' '
vim.g.airline_extensions_tabline_left_alt_sep = '|'
vim.g.airline_extensions_tabline_formatter = 'default'
vim.g.airline_powerline_fonts = 1

-- Set miscellaneous configurations
vim.o.mouse = 'a'
vim.cmd('colorscheme gruvbox')
vim.o.clipboard = 'unnamed'
vim.o.showmatch = true
vim.o.tabstop = 4
vim.o.softtabstop = 2
vim.o.shiftwidth = 4
vim.o.filetype = 'on'
vim.o.foldlevelstart = 10
vim.o.clipboard = 'unnamedplus'
vim.o.signcolumn = 'number'
vim.o.encoding = 'UTF-8'
vim.o.updatetime = 300
vim.o.foldnestmax = 40
vim.o.tabpagemax = 10
vim.o.laststatus = 2
vim.o.foldcolumn ='2'
vim.o.scrolloff = 8
vim.o.foldenable = true
vim.o.showmode = false
vim.o.expandtab = true
vim.o.linebreak = true
vim.o.wildmenu = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.undofile = true
vim.o.wrap = false
vim.o.hidden = true
vim.o.number = true
vim.cmd('syntax on')
vim.o.ruler = true
vim.o.title = true
vim.cmd('set nocompatible')


-- Display nerdtree when enter
vim.cmd[[
autocmd VimEnter * NERDTree | wincmd p
let g:NERDTreeShowHidden = 1
let g:NERDTreeWinSize = 25
]]


-- Set foldmethod for JavaScript documents
vim.cmd[[autocmd FileType javascript set foldmethod=marker]]

-- Example using a list of specs with the default options
vim.g.mapleader = " " -- Make sure to set `mapleader` before lazy so your mappings are correct
