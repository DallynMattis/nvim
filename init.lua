-- ============================================================
--  NEOVIM CONFIG — init.lua
--  lazy.nvim est le gestionnaire de plugins : il installe et charge tout
-- ============================================================

-- {{{ Bootstrap lazy.nvim
-- Si lazy.nvim n'est pas installé, on le télécharge automatiquement
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
-- }}}

-- ============================================================
--  DÉFINITIONS DES PLUGINS
--  Chaque plug_xxx() retourne la configuration d'un plugin
-- ============================================================

-- {{{ ALE — formate le code à la sauvegarde (prettier, stylua...) et détecte les erreurs
-- Usage : :ALEFix  →  forcer le formatage maintenant
-- ale_disable_lsp = 1 : évite les doublons car LSP détecte déjà les erreurs
local function plug_ale()
  vim.g.ale_fix_on_save = 1
  vim.g.ale_disable_lsp = 1
  return {
    "dense-analysis/ale",
    ft     = "typescript,javascript,json,yaml,markdown,css,scss,html,vue,lua,go",
    config = function()
      -- Outil de vérification par langage
      vim.g.ale_linters = {
        go   = { "golangci-lint", "gofmt" },
        yaml = { "yamllint", "spectral" },
        html = { "tidy" },
      }
      -- Outil de formatage par langage
      vim.g.ale_fixers = {
        typescript = { "prettier" },
        javascript = { "prettier" },
        json       = { "prettier" },
        yaml       = { "prettier" },
        markdown   = { "prettier" },
        css        = { "prettier" },
        scss       = { "prettier" },
        html       = { "prettier" },
        vue        = { "prettier" },
        lua        = { "stylua" },
      }
    end,
  }
end
-- }}}

-- {{{ go.nvim — support complet du langage Go (imports auto, tests, refacto...)
-- Se charge uniquement quand tu ouvres un fichier .go ou go.mod
-- Le formatage à la sauvegarde est géré par gopls (LSP) pour éviter le double format
local function plug_x_go()
  return {
    "ray-x/go.nvim",
    ft           = { "go", "gomod" },
    build        = ':lua require("go.install").update_all_sync()',
    dependencies = {
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
      vim.cmd("autocmd FileType go setlocal foldmethod=indent")
    end,
  }
end
-- }}}

-- {{{ Treesitter — comprend vraiment la syntaxe du code → meilleure colorisation qu'un simple regex
-- Usage : :TSInstall <langage>  pour ajouter un langage  |  :TSUpdate all  pour tout mettre à jour
local function plug_treesitter()
  return {
    "nvim-treesitter/nvim-treesitter",
    event  = "BufRead",
    build  = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "go", "javascript", "typescript", "bash", "json", "yaml" },
        auto_install     = true,   -- installe le parser automatiquement quand tu ouvres un nouveau type de fichier
        sync_install     = false,
        ignore_install   = {},
        highlight        = { enable = true },
        incremental_selection = {
          enable  = true,
          keymaps = {
            init_selection    = "<CR>",    -- commence la sélection
            scope_incremental = "<CR>",    -- étend au scope suivant
            node_incremental  = "<TAB>",   -- étend au bloc parent
            node_decremental  = "<S-TAB>", -- réduit au bloc enfant
          },
        },
        modules = {},
      })
    end,
  }
end
-- }}}

-- {{{ LSP — le cerveau de l'éditeur : autocomplétion, erreurs en direct, "aller à la définition"
-- Usage : :LspInfo  →  voir quels serveurs sont actifs sur le fichier courant
--
-- Installer les serveurs de langage (une seule fois, sur la machine) :
--   JS/TS   : npm install -g typescript typescript-language-server
--   Bash    : npm install -g bash-language-server
--   JSON    : npm install -g vscode-langservers-extracted
--   Lua     : brew install lua-language-server
--   Go      : go install golang.org/x/tools/gopls@latest
local function plug_lspconfig()
  return {
    "neovim/nvim-lspconfig",
    opts   = { inlay_hints = { enabled = true } }, -- affiche des hints discrets dans le code (types, noms de params...)
    config = function()

      -- Serveur pour JavaScript, TypeScript et Vue
      vim.lsp.config("ts_ls", {
        capabilities = require("coq").lsp_ensure_capabilities(), -- branche l'autocomplétion COQ
        init_options = { preferences = { disableSuggestions = true } },
        filetypes    = { "javascript", "typescript", "vue" },
      })
      vim.lsp.enable("ts_ls")
      vim.cmd("autocmd FileType typescript setlocal foldmethod=syntax")

      -- Serveur pour les scripts Bash
      vim.lsp.config("bashls", {})
      vim.lsp.enable("bashls")

      -- Serveur pour Python
      vim.lsp.config("pylsp", {})
      vim.lsp.enable("pylsp")

      -- Serveur pour Go — active le formatage strict (gofumpt) et l'analyse statique (staticcheck)
      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            analyses    = { unusedparams = true }, -- signale les paramètres de fonctions inutilisés
            staticcheck = true,
            gofumpt     = true,                    -- formatage plus strict que gofmt standard
          },
        },
      })
      vim.lsp.enable("gopls")

      -- Serveur pour JSON
      vim.lsp.config("jsonls", {})
      vim.lsp.enable("jsonls")

      -- Serveur pour les Makefile
      vim.lsp.config("autotools_ls", {})
      vim.lsp.enable("autotools_ls")

      -- Serveur pour Lua — configuré pour reconnaître l'environnement Neovim (vim.*, etc.)
      vim.lsp.config("lua_ls", {
        on_init = function(client)
          local path = client.workspace_folders[1].name
          if not vim.uv.fs_stat(path .. "/.luarc.json") and not vim.uv.fs_stat(path .. "/.luarc.jsonc") then
            client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
              Lua = {
                runtime   = { version = "LuaJIT" },
                workspace = {
                  checkThirdParty = false,
                  library         = { vim.env.VIMRUNTIME }, -- donne accès aux APIs Neovim
                },
              },
            })
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
          end
          return true
        end,
      })
      vim.lsp.enable("lua_ls")
    end,
  }
end
-- }}}

-- {{{ nvim-tree — arbre de fichiers sur la gauche, s'ouvre automatiquement au démarrage
local function plug_nvim_tree()
  -- Ouvre l'arbre mais remet le focus sur la fenêtre d'édition (pas sur l'arbre)
  local function open_on_start()
    if not vim.g.started_by_firenvim then
      require("nvim-tree.api").tree.open()
      vim.cmd(":wincmd w")
    end
  end

  return {
    "nvim-tree/nvim-tree.lua",
    version      = "*",
    lazy         = false,
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- icônes de fichiers colorées
    config       = function()
      require("nvim-tree").setup({
        sort     = { sorter = "case_sensitive" },
        view     = { width = 30 },
        renderer = { group_empty = true },  -- regroupe les dossiers vides sur une ligne
        filters  = { dotfiles = false },    -- affiche les fichiers cachés (.env, .gitignore...)
      })
      vim.api.nvim_create_autocmd("VimEnter", { callback = open_on_start })
    end,
  }
end
-- }}}

-- {{{ vim-better-whitespace — surligne les espaces inutiles en fin de ligne et les supprime à la sauvegarde
-- Usage : :StripWhitespace  →  nettoyer manuellement sans sauvegarder
local function plug_trailing_whitespaces()
  return {
    "ntpeters/vim-better-whitespace",
    version = "*",
    event   = "BufEnter",
    config  = function()
      -- Désactivé dans ces types de fichiers (ils ont leurs propres règles d'espacement)
      vim.g.better_whitespace_filetypes_blacklist =
        { "diff", "gitcommit", "unite", "qf", "help", "mail", "startify", "git", "taskedit", "csv" }
      vim.g.show_spaces_that_precede_tabs = 1  -- signale aussi les espaces avant les tabs
      vim.g.better_whitespace_enabled     = 1
      vim.g.strip_whitespace_on_save      = 1  -- nettoyage automatique à chaque sauvegarde
      vim.g.strip_whitespace_confirm      = 0  -- sans demander confirmation
      vim.g.startify_change_to_dir        = 0
    end,
  }
end
-- }}}

-- {{{ noice.nvim — remplace la barre de commande et les notifs par des fenêtres flottantes modernes
local function plug_noice()
  return {
    "folke/noice.nvim",
    event        = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config       = function()
      require("noice").setup({
        lsp = {
          -- Utilise Treesitter pour rendre la doc LSP plus jolie
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"]                = true,
          },
        },
        presets = {
          bottom_search         = true,  -- barre de recherche reste en bas (comportement classique)
          command_palette       = true,  -- cmdline + suggestions affichées ensemble
          long_message_to_split = true,  -- les longs messages s'ouvrent dans un split plutôt qu'une popup
        },
      })
    end,
  }
end
-- }}}

-- {{{ lualine — barre de statut en bas (mode, branche git, fichier, erreurs, position...)
local function plug_lualine()
  return {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require("lualine").setup({
        options = {
          theme                = "auto",  -- s'adapte automatiquement au colorscheme actif
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },                           -- NORMAL / INSERT / VISUAL...
          lualine_b = { "branch", "diff", "diagnostics" },  -- branche git + lignes modifiées + erreurs LSP
          lualine_c = { { "filename", path = 1 } },         -- chemin relatif du fichier ouvert
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },                       -- % de progression dans le fichier
          lualine_z = { "location" },                       -- ligne:colonne
        },
        tabline = {
          lualine_a = { "buffers" }, -- tous les buffers ouverts affichés tout en haut
          lualine_z = { "tabs" },
        },
      })
    end,
  }
end
-- }}}

-- {{{ gitsigns — montre en temps réel les lignes modifiées/ajoutées/supprimées + qui a écrit chaque ligne
local function plug_gitsigns()
  return {
    "lewis6991/gitsigns.nvim",
    event  = "BufRead",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" }, -- ligne ajoutée (vert)
          change       = { text = "▎" }, -- ligne modifiée (orange)
          delete       = { text = "" }, -- ligne supprimée (rouge)
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
          untracked    = { text = "▎" },
        },
        current_line_blame      = true,        -- affiche en gris "qui a écrit cette ligne et quand" après 1s
        current_line_blame_opts = { delay = 1000 },
        sign_priority           = 6,
        update_debounce         = 100,
        on_attach = function(bufnr)
          local gs  = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          -- Naviguer entre les blocs de modifications
          map("n", "]c", gs.next_hunk, "Git: Bloc de modif suivant")
          map("n", "[c", gs.prev_hunk, "Git: Bloc de modif précédent")
          -- Actions sur le bloc sous le curseur
          map("n", "<leader>gs", gs.stage_hunk,   "Git: Stager ce bloc")
          map("n", "<leader>gr", gs.reset_hunk,   "Git: Annuler ce bloc")
          map("n", "<leader>gp", gs.preview_hunk, "Git: Voir les changements de ce bloc")
          map("n", "<leader>gb", gs.blame_line,   "Git: Voir qui a écrit cette ligne")
        end,
      })
    end,
  }
end
-- }}}

-- {{{ indent-blankline — dessine des lignes verticales │ pour visualiser les niveaux d'indentation
local function plug_indent_blankline()
  return {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = "BufRead",
    opts  = {
      indent  = { char = "│" },
      scope   = { enabled = true, show_start = true }, -- met en évidence le bloc d'indentation courant
      exclude = {
        -- Pas de guides dans ces types de buffers (inutile et moche)
        filetypes = { "help", "dashboard", "NvimTree", "lazy", "mason", "notify" },
      },
    },
  }
end
-- }}}

-- {{{ alpha-nvim — page d'accueil avec raccourcis qui s'affiche quand tu ouvres nvim sans fichier
local function plug_alpha()
  return {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      local alpha     = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
        "                                                     ",
      }

      dashboard.section.buttons.val = {
        dashboard.button("f", "  Fichier récent",  ":Telescope oldfiles<CR>"),
        dashboard.button("e", "  Nouveau fichier", ":ene <BAR> startinsert<CR>"),
        dashboard.button("p", "  Projets",         ":Telescope find_files<CR>"),
        dashboard.button("l", "󰒲  Lazy",            ":Lazy<CR>"),
        dashboard.button("q", "  Quitter",         ":qa<CR>"),
      }

      alpha.setup(dashboard.opts)
    end,
  }
end
-- }}}

-- ============================================================
--  LISTE DES PLUGINS
-- ============================================================
require("lazy").setup({

  -- Thèmes de couleurs
  { "rebelot/kanagawa.nvim" },         -- thème actif : bleu nuit japonais
  { "morhetz/gruvbox" },               -- thème de secours
  { "rafi/awesome-vim-colorschemes" }, -- collection de thèmes supplémentaires

  -- Autocomplétion
  { "ms-jpq/coq_nvim" },              -- suggère du code pendant que tu tapes

  -- LSP et support des langages
  plug_lspconfig(),
  plug_treesitter(),
  plug_x_go(),
  plug_ale(),
  { "pangloss/vim-javascript" },             -- coloration syntaxique JS améliorée
  { "grvcoelho/vim-javascript-snippets" },   -- snippets JS prêts à l'emploi
  { "mechatroner/rainbow_csv" },             -- chaque colonne CSV dans une couleur différente

  -- PlantUML (diagrammes)
  { "aklt/plantuml-syntax" },               -- coloration des fichiers .puml
  { "weirongxu/plantuml-previewer.vim" },   -- prévisualisation des diagrammes dans le navigateur
  { "tyru/open-browser.vim" },             -- requis par plantuml-previewer pour ouvrir le navigateur

  -- Explorateur de fichiers et navigation
  plug_nvim_tree(),
  { "folke/which-key.nvim" },         -- affiche les raccourcis disponibles quand tu hésites
  { "liuchengxu/vista.vim" },         -- liste les fonctions/classes du fichier comme un sommaire (nécessite: brew install --HEAD universal-ctags)
  { "Jremmen/vim-ripgrep" },          -- recherche de texte ultra-rapide dans tous les fichiers du projet

  -- Git
  { "tpope/vim-fugitive" },           -- commandes git dans nvim : :Git status, :Git commit, :Git push...
  plug_gitsigns(),

  -- Utilitaires d'édition
  { "tpope/vim-surround" },                                       -- entourer/changer les guillemets et parenthèses : ys pour ajouter, cs pour changer, ds pour supprimer
  { "tpope/vim-commentary" },                                     -- commenter/décommenter : gcc sur une ligne, gc sur une sélection
  { "tpope/vim-unimpaired" },                                     -- raccourcis en paires : ]q [q pour naviguer dans quickfix, ]b [b pour les buffers, etc.
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} }, -- ferme automatiquement les (, [, {, ", '
  { "kshenoy/vim-signature" },                                    -- affiche tes marques vim dans la gouttière (m + lettre pour poser une marque)
  { "honza/vim-snippets" },                                       -- banque de snippets pour tous les langages
  { "junegunn/vim-peekaboo" },                                    -- prévisualise le contenu des registres quand tu appuies sur " ou @

  -- Client REST
  { "diepm/vim-rest-console" },       -- envoie des requêtes HTTP depuis un fichier .rest directement dans nvim

  -- AI
  { "ravitemer/mcphub.nvim" },        -- gère les serveurs MCP (protocole pour brancher des outils AI à nvim)

  -- UI et apparence
  plug_lualine(),
  plug_noice(),
  plug_indent_blankline(),
  plug_alpha(),
  plug_trailing_whitespaces(),
  {
    "NvChad/nvim-colorizer.lua",      -- affiche la vraie couleur derrière les codes CSS : #fff, rgb(255,0,0), etc.
    event  = "BufRead",
    config = function()
      require("colorizer").setup({ "*" }, {
        RGB    = true, RRGGBB = true,
        names  = true, css    = true, css_fn = true,
        mode   = "background",
      })
    end,
  },

  -- Fun
  { "alec-gibson/nvim-tetris" },      -- tetris dans nvim avec :Tetris
})

-- ============================================================
--  OPTIONS GÉNÉRALES
-- ============================================================
vim.o.termguicolors = true           -- active les vraies couleurs 24-bit (requis par colorizer, lualine, kanagawa...)
vim.o.mouse        = "a"             -- souris activée dans tous les modes
vim.o.clipboard    = "unnamedplus"   -- Ctrl+C/V communique avec le presse-papiers système
vim.o.number       = true            -- numéros de ligne
vim.o.showmatch    = true            -- flashe la parenthèse/accolade correspondante quand tu en fermes une
vim.o.showmode     = false           -- inutile : lualine affiche déjà le mode en bas
vim.o.ruler        = true            -- affiche la position du curseur (ligne:colonne) en bas à droite
vim.o.title        = true            -- affiche le nom du fichier dans le titre du terminal
vim.o.hidden       = true            -- permet de changer de buffer sans avoir à sauvegarder d'abord
vim.o.wrap         = false           -- pas de retour à la ligne automatique
vim.o.linebreak    = true            -- si wrap est activé, coupe aux mots entiers (pas au milieu d'un mot)
vim.o.scrolloff    = 8              -- garde toujours 8 lignes visibles au-dessus et en-dessous du curseur
vim.o.wildmenu     = true            -- autocomplétion des commandes vim avec la touche Tab
vim.o.encoding     = "UTF-8"
vim.o.updatetime   = 300             -- délai en ms avant que LSP et gitsigns se mettent à jour
vim.o.signcolumn   = "number"        -- les icônes git/erreurs remplacent les numéros de ligne (économise de l'espace)
vim.o.laststatus   = 2              -- la barre de statut (lualine) est toujours visible

-- Indentation
vim.o.tabstop      = 4              -- une tabulation s'affiche comme 4 espaces
vim.o.softtabstop  = 2              -- Tab et Backspace en mode insertion bougent de 2 espaces
vim.o.shiftwidth   = 4              -- >> et << indentent/désindentent de 4 espaces
vim.o.expandtab    = true            -- la touche Tab insère des espaces (pas un vrai caractère tab)

-- Sauvegarde et historique
vim.o.backup       = false           -- pas de fichiers de sauvegarde temporaires (genre fichier~)
vim.o.writebackup  = false
vim.o.undofile     = true            -- garde l'historique d'annulation même après avoir fermé le fichier

-- Pliage de code (les {{{ }}} dans ce fichier créent des sections pliables)
vim.o.foldmethod   = "marker"        -- {{{ ouvre une section, }}} la ferme — za pour plier/déplier
vim.o.foldlevelstart = 10            -- au démarrage, tout est ouvert (niveau 10 = presque tout)
vim.o.foldnestmax  = 40              -- niveau maximum d'imbrication de pliage
vim.o.foldcolumn   = "2"             -- colonne sur la gauche qui montre les indicateurs de pliage
vim.o.foldenable   = true
vim.o.tabpagemax   = 10              -- maximum 10 onglets ouverts en même temps

-- ============================================================
--  THÈME DE COULEURS
-- ============================================================
vim.cmd([[colorscheme gruvbox]])

-- ============================================================
--  MÉTHODE DE PLIAGE PAR TYPE DE FICHIER
--  (chaque langage a sa propre logique d'indentation)
-- ============================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "javascript" },
  callback = function() vim.opt_local.foldmethod = "marker" end,   -- JS : pliage par {{{ }}}
})
vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "go", "golang" },
  callback = function() vim.opt_local.foldmethod = "indent" end,   -- Go : pliage par indentation
})
vim.api.nvim_create_autocmd("FileType", {
  pattern  = { "typescript" },
  callback = function() vim.opt_local.foldmethod = "syntax" end,   -- TS : pliage par syntaxe
})

-- ============================================================
--  RACCOURCIS CLAVIER GLOBAUX
-- ============================================================
vim.keymap.set("v", "//",             'y/<C-R>"<CR>', { noremap = true,                desc = "Rechercher le texte sélectionné" })
vim.keymap.set({ "n", "v" }, "<C-c>", '"+y',          { noremap = true, silent = true, desc = "Copier vers le presse-papiers système" })
vim.keymap.set("n", "///",            ":nohl<CR>",    { noremap = true,                desc = "Effacer la surbrillance de recherche" })

-- ============================================================
--  RACCOURCIS LSP (actifs uniquement quand un serveur de langage est attaché au fichier)
-- ============================================================
vim.api.nvim_create_autocmd("LspAttach", {
  group    = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local wk   = require("which-key")
    local opts = { buffer = ev.buf }

    -- Navigation dans le code (préfixe g)
    wk.add({ { "gd", "<cmd>lua vim.lsp.buf.definition()<cr>",     desc = "Aller à la définition" } })
    wk.add({ { "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>",    desc = "Aller à la déclaration" } })
    wk.add({ { "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", desc = "Aller à l'implémentation" } })
    wk.add({ { "gr", "<cmd>lua vim.lsp.buf.references()<cr>",     desc = "Voir toutes les utilisations" } })

    -- Actions LSP (préfixe <leader>l — par défaut \ puis l)
    wk.add({
      { "<leader>l",  group = "LSP" },
      { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>",            desc = "Actions disponibles sur ce code" },
      { "<leader>lf", "<cmd>lua vim.lsp.buf.format { async = true }<cr>",  desc = "Formater le fichier entier" },
      { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>",                 desc = "Renommer ce symbole partout" },
    })

    -- Raccourcis divers
    vim.keymap.set("n", "K",         vim.lsp.buf.hover,          opts) -- affiche la doc du mot sous le curseur
    vim.keymap.set("n", "<C-k>",     vim.lsp.buf.signature_help, opts) -- affiche la signature de la fonction
    vim.keymap.set("n", "<space>D",  vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename,          opts)
    vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<space>f",  function()
      vim.lsp.buf.format({ async = true })
    end, opts)
    -- Gestion des dossiers de workspace LSP (rarement utile au quotidien)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder,    opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
  end,
})
