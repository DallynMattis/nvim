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
    --{'vim-airline/vim-airline-themes'},
    {'rafi/awesome-vim-colorschemes'},
    {'ap/vim-css-color'},
    {'honza/vim-snippets'},
    {'jiangmiao/auto-pairs'},
    --{'neoclide/coc.nvim'},
    --{'fannheyward/coc-pyright'},
    {'rebelot/kanagawa.nvim'},
 --[[   {
        "hrsh7th/nvim-cmp",
        opts = {
          sources = {
            -- other sources
            {
              name = "html-css",
              option = {
                enable_on = {
                  "html",
                }, -- set the file types you want the plugin to work on
                file_extensions = { "css", "sass", "less" }, -- set the local filetypes from which you want to derive classes
                style_sheets = {
                  -- example of remote styles, only css no js for now
                  "https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css",
                },
              },
            },
          },
        },
      },
      {
        "Jezda1337/nvim-html-css",
        dependencies = {
          "nvim-treesitter/nvim-treesitter",
          "nvim-lua/plenary.nvim",
        },
        config = function()
          require("html-css"):setup()
        end,
      },]]
    })







--Airline display configuration
vim.g.airline_extensions_tabline_enabled = 1
vim.g.airline_extensions_tabline_left_sep = ' '
vim.g.airline_extensions_tabline_left_alt_sep = '|'
vim.g.airline_extensions_tabline_formatter = 'default'
vim.g.airline_powerline_fonts = 1

-- Set miscellaneous configurations
vim.o.mouse = 'a'
vim.cmd('colorscheme kanagawa')
vim.o.clipboard = 'unnamed'
vim.o.showmatch = true
vim.o.tabstop = 4
vim.o.softtabstop = 2
vim.o.shiftwidth = 4
vim.o.filetype = 'on'
vim.o.foldlevelstart = 10
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




--[[  Use win32yank for clipboard integration in WSL

local o =vim.o
local wo=vim.wo

wo.nu=true
wo.rnu=true
vim.o.clipboard = 'unnamedplus'

o.expandtab= true
o.tabstop =4
o.shiftwidth =4

  vim.g.clipboard = {
    name = 'win32yank-wsl',
    copy = {
      ['+'] = 'win32yank.exe -i --crlf',
      ['*'] = 'win32yank.exe -i --crlf',
    },
    paste = {
      ['+'] = 'win32yank.exe -o --lf',
      ['*'] = 'win32yank.exe -o --lf',
    },
    cache_enabled = true,
  }

  ]]

-- Use xclip for clipboard integration
vim.api.nvim_set_var('clipboard', {
  name = 'xclip',
  copy = { ['+'] = 'xclip -selection clipboard', ['*'] = 'xclip -selection clipboard' },
  paste = { ['+'] = 'xclip -selection clipboard -o', ['*'] = 'xclip -selection clipboard -o' },
  cache_enabled = 0,
})


