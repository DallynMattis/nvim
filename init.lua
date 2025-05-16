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
				go = { "golint", "go vet", "staticcheck" },
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

			-- For Makefile
			require("lspconfig").autotools_ls.setup({})

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
					dotfiles = false,
				},
			})
			-- launch at start
			vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
		end,
	}
end

local function plug_avente()
	return {
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
		opts = {
			behaviour = {
				auto_suggestions = false, -- Experimental stage
			},
			auto_suggestions_provider = "openai-llmproxy",
			provider = "claude-llmproxy", -- Recommend using Claude
			-- provider = "claude", -- Recommend using Claude
			claude = {
				endpoint = "https://api.anthropic.com",
				model = "claude-3-5-sonnet-20241022",
				temperature = 0,
				max_tokens = 4096,
			},
			vendors = {
				["claude-llmproxy"] = {
					endpoint = "https://llmproxy.ai.orange",
					__inherited_from = "openai",
					model = "vertex_ai/claude3.5-sonnet-v2",
					timeout = 30000, -- Timeout in milliseconds
					temperature = 0,
					max_tokens = 8000,
				},
				["openai-llmproxy"] = {
					endpoint = "https://llmproxy.ai.orange",
					__inherited_from = "openai",
					model = "openai/gpt-4o-mini",
					timeout = 30000, -- Timeout in milliseconds
					temperature = 0,
					max_tokens = 8000,
				},
			},
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make",
		dependencies = {
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	}
end

---- {{{ Adding plugin to highlight trailing whitespace
-- https://github.com/ntpeters/vim-better-whitespace
-- To launch manual stripping of whitespaces :
-- :StripWhitespace
local function plug_trailing_whitespaces()
	return {
		"ntpeters/vim-better-whitespace",
		version = "*",
		event = { "BufEnter" },
		config = function()
			vim.g.better_whitespace_filetypes_blacklist =
				{ "diff", "gitcommit", "unite", "qf", "help", "mail", "startify", "git", "taskedit", "csv", "minimap" }
			-- To highlight space characters that appear before or in-between tabs
			vim.g.show_spaces_that_precede_tabs = 1
			-- To enable highlighting of trailing whitespace
			vim.g.better_whitespace_enabled = 1
			-- Enabling stripping on save (with confirmation)
			vim.g.strip_whitespace_on_save = 1
			vim.g.startify_change_to_dir = 0
			--  Note that overwriting this with a b: is ignored
			vim.g.strip_whitespace_confirm = 0
		end,
	}
end
-- }}}
require("lazy").setup({
	{ "iCyMind/NeoSolarized" },
	{ "alec-gibson/nvim-tetris" },
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
	{ "liuchengxu/vista.vim" }, -- utilise librairie ctags : brew install --HEAD universal-ctags/universal-ctags/universal-ctags
	{ "ms-jpq/coq_nvim" },
	plug_trailing_whitespaces(),
	plug_treesitter(),
	plug_x_go(),
	plug_ale(),
	plug_lspconfig(),
	plug_nvim_tree(),
	plug_avente(),
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
