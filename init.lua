--Installer LazyLoad
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

-- {{{ ALE : Asynchronous Lint Engine
-- Linter.
-- see : https://github.com/dense-analysis/ale
-- Usage : :ALEFix to make Prettier fix the file
--   see g:ale_fixers below
local function plug_ale()
	-- Enable automatic fixing on save
	vim.g.ale_fix_on_save = 1
	-- define a new alias ":Prettier" as an alias to ALEFix
	vim.cmd('command! -nargs=0 Prettier echo "Use :ALEFix"')
	return {
		"dense-analysis/ale",
		ft = "typescript,json,yaml,markdown,css,scss,html,vue,lua,go",
		config = function()
			vim.g.ale_linters = {
				-- golangci-lint calls numerous linters in the background
				-- requires a project local config file
				go = { "golint", "go vet", "golangci-lint", "staticcheck" },
				yaml = { "yamllint", "spectral" },
				html = { "tidy" },
			}
			vim.g.ale_fixers = {
				typescript = { "prettier" },
				javascript = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				html = { "prettier" },
				vue = { "prettier" },
				lua = { "stylua" },
			}
			-- key mapping to Fix the file
		end,
	}
end
-- }}}

-- {{{ Plugin to support Go Language (golang)
-- https://github.com/ray-x/go.nvim
-- Replaces fatih/vim-go written in vimscript mostly
-- Rem : needs to install a tree-sitter parser
--`:TSInstallSync go`
-- For debugging, see https://github.com/mfussenegger/nvim-dap
local function plug_x_go()
	return {
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup()
			-- foldmethod
			vim.cmd("autocmd FileType go setlocal foldmethod=indent")

			-- Run gofmt on save
			local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.go",
				callback = function()
					require("go.format").gofmt()
				end,
				group = format_sync_grp,
			})
		end,
		ft = { "go", "gomod" }, -- Lazy load on filetype go
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	}
end
-- }}}/!\ IMPORTANT
-- {{{ Treesitter : syntax highlighter
-- see : https://github.com/nvim-treesitter/nvim-treesitter
-- TSInstallInfo Pour voir les langages installés pour les highlighters
-- Usage : TSInstall <language> pour installer un highlighter
-- Puis : TSEnable highlight pour activer le highlighter
-- :TSUpdate all
local function plug_treesitter()
	return {
		"nvim-treesitter/nvim-treesitter",
		event = "BufRead",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- A list of parser names, or "all" (the five listed parsers should always be installed)
				ensure_installed = { "lua", "go" },
				-- Automatically install missing parsers when entering buffer
				-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
				auto_install = false,
				-- List of parsers to ignore installing (or "all")
				ignore_install = {},
				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = true,
				highlight = {
					enable = true,
				},
				-- indent = {
				--   enable = true
				-- },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<CR>", -- set to `false` to disable one of the mappings
						scope_incremental = "<CR>",
						node_incremental = "<TAB>",
						node_decremental = "<S-TAB>",
					},
				},
				modules = {},
			})
		end,
	}
end
--}}}
-- {{{ LSP config
-- https://github.com/neovim/nvim-lspconfig
-- See : LspInfo
local function plug_lspconfig()
	return {
		"neovim/nvim-lspconfig",
		opts = {
			inlay_hints = { enabled = true },
		},
		config = function()
			vim.lsp.set_log_level("debug")

			-- For JavaScript and TypeScript
			--
			-- See doc here : https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver
			-- npm install -g typescript typescript-language-server
			-- brew install coq
			require("lspconfig").ts_ls.setup({

				-- to support COQ snippets
				capabilities = require("coq").lsp_ensure_capabilities(),

				init_options = {
					preferences = {
						disableSuggestions = true,
					},
				},
				filetypes = {
					"javascript",
					"typescript",
					"vue",
				},
			})
			vim.cmd("autocmd FileType typescript setlocal foldmethod=syntax")

			-- For bash
			-- see doc here https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#bashls
			-- npm install -g bash-language-server
			require("lspconfig").bashls.setup({})

			-- For Python

			require("lspconfig").pylsp.setup({})
			-- For Golang
			-- see doc here https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#gopls
			require("lspconfig").gopls.setup({
				settings = {
					gopls = {
						analyses = {
							unusedparams = true,
						},
						staticcheck = true,
						gofumpt = true,
					},
				},
			})
			-- For JSON
			-- see doc here https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls
			-- npm install -g vscode-langservers-extracted
			require("lspconfig").jsonls.setup({})

			-- For Lua
			-- Install server using `brew install lua-language-server`
			-- See setup config here https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
			require("lspconfig").lua_ls.setup({
				on_init = function(client)
					local path = client.workspace_folders[1].name
					if
						not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc")
					then
						client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
							Lua = {
								runtime = {
									-- Tell the language server which version of Lua you're using
									-- (most likely LuaJIT in the case of Neovim)
									version = "LuaJIT",
								},
								-- Make the server aware of Neovim runtime files
								workspace = {
									checkThirdParty = false,
									library = {
										vim.env.VIMRUNTIME,
										-- "${3rd}/luv/library"
										-- "${3rd}/busted/library",
									},
									-- or pull in all of 'runtimepath'. NOTE: this is a lot slower
									-- library = vim.api.nvim_get_runtime_file("", true)
								},
							},
						})

						client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					end
					return true
				end,
			})
		end,
	}
end
--- }}}
---
local function open_nvim_tree()
  -- open the tree
  if not vim.g.started_by_firenvim then
    require("nvim-tree.api").tree.open()
    -- do not leave focus on tree
    vim.cmd(":wincmd w")
  end
end
-- Display nvim-tree
local function plug_nvim_tree()
	return {
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup({
				sort = {
					sorter = "case_sensitive",
				},
				view = {
					width = 30,
				},
				renderer = {
					group_empty = true,
				},
				filters = {
					dotfiles = true,
				},
			})
			-- launch at start
            vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
		end,
	}
end

--
require("lazy").setup({
	{ "iCyMind/NeoSolarized" },
	{ "nvim-treesitter/nvim-treesitter" },
	{ "ryanoasis/vim-devicons" },
	{ "pangloss/vim-javascript" },
	{ "prettier/vim-prettier", run = "yarn install --frozen-lockfile --production" },
	{ "Jremmen/vim-ripgrep" },
	{ "mhinz/vim-startify" },
	{ "grvcoelho/vim-javascript-snippets" },
	{ "tpope/vim-commentary" },
	{ "preservim/nerdcommenter" },
	{ "tpope/vim-surround" },
	{ "morhetz/gruvbox" },
	{ "pangloss/vim-javascript" },
	{ "grvcoelho/vim-javascript-snippets" },
	{ "kshenoy/vim-signature" },
	{ "aklt/plantuml-syntax" },
	{ "mechatroner/rainbow_csv" },
	{ "matveyt/neoclip" },
	{ "tpope/vim-fugitive" },
	{ "diepm/vim-rest-console" },
	{ "vim-airline/vim-airline" },
	{ "rafi/awesome-vim-colorschemes" },
	{ "ap/vim-css-color" },
	{ "honza/vim-snippets" },
	{ "jiangmiao/auto-pairs" },
	{ "github/copilot.vim" },
	{ "rebelot/kanagawa.nvim" },
	{ "raghur/vim-ghost" },
	{ "folke/which-key.nvim" },
	{ "neovim/nvim-lspconfig" },
	{ "liuchengxu/vista.vim" },
	{ "ms-jpq/coq_nvim" },
	plug_treesitter(),
	plug_x_go(),
	plug_ale(),
	plug_lspconfig(),
	plug_nvim_tree(),
})

-- set foldmethod for files
-- Set default foldmethod to 'indent'
vim.opt.foldmethod = "indent"

--Airline display configuration
vim.g.airline_extensions_tabline_enabled = 1
vim.g.airline_extensions_tabline_left_sep = " "
vim.g.airline_extensions_tabline_left_alt_sep = "|"
vim.g.airline_extensions_tabline_formatter = "default"
vim.g.airline_powerline_fonts = 1

-- Set miscellaneous configurations
vim.opt.foldmethod = "marker"
vim.o.mouse = "a"
vim.o.clipboard = "unnamed"
vim.o.showmatch = true
vim.o.tabstop = 4
vim.o.softtabstop = 2
vim.o.shiftwidth = 4
vim.o.filetype = "on"
vim.o.foldlevelstart = 10
vim.o.signcolumn = "number"
vim.o.encoding = "UTF-8"
vim.o.updatetime = 300
vim.o.foldnestmax = 40
vim.o.tabpagemax = 10
vim.o.laststatus = 2
vim.o.foldcolumn = "2"
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
vim.cmd("syntax on")
vim.o.ruler = true
vim.o.title = true
vim.cmd("set nocompatible")

--python3
vim.g.python3_host_prog = "/usr/bin/python3"

-- tabby configuration
-- vim.g.tabby_keybinding_accept = '<Tab>'

vim.cmd([[autocmd FileType javascript set foldmethod=marker]])
vim.cmd([[autocmd FileType golang set foldmethod=indent]])

-- set colorscheme
vim.cmd([[colorscheme gruvbox]])

-- shortcuts
-- Allow search of currently selected text using //
vim.api.nvim_set_keymap("v", "//", 'y/<C-R>"<CR>', { noremap = true })
-- Copier vers le presse-papiers système
vim.api.nvim_set_keymap("n", "<C-c>", '"+y', { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-c>", '"+y', { noremap = true, silent = true })

-- Allow clearing of searched text using ///
vim.api.nvim_set_keymap("n", "///", ":nohl<CR>", { noremap = true })

-- Use LspAttach autocommand to only map the following keys after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local wk = require("which-key")
		-- g prefix
		wk.add({ { "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", desc = "LSP Goto Definition" } })
		wk.add({ { "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", desc = "LSP Goto Declaration" } })
		wk.add({ { "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "LSP Goto Implementation" } })
		wk.add({ { "gr", "<cmd>lua vim.lsp.buf.references()<cr>", desc = "LSP Goto References" } })
		-- leader prefix
		wk.add({
			{ "<leader>l", group = "LSP" },
			{ "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "LSP Code Action" },
			{ "<leader>lf", "<cmd>lua vim.lsp.buf.format { async = true }<cr>", desc = "LSP Format" },
			{ "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "LSP Rename" },
		})

		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})
