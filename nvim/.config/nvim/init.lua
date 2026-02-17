vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Core Options
vim.opt.number = true
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.mouse = "n"

-- Performance: Reduce regex engine usage
vim.opt.regexpengine = 1

-- Theme detection (simplified)
local function detect_os_theme()
	if vim.fn.has("mac") == 1 then
		local handle = io.popen("defaults read -g AppleInterfaceStyle 2>/dev/null")
		if handle then
			local result = handle:read("*a")
			handle:close()
			return result and result:match("Dark") and "dark" or "light"
		end
	end
	return "dark"
end

vim.opt.background = detect_os_theme()

-- Auto-detect theme changes when focus returns to nvim
local function reload_theme_if_changed()
	local current_bg = vim.opt.background:get()
	local detected_bg = detect_os_theme()

	if current_bg ~= detected_bg then
		vim.opt.background = detected_bg
		if pcall(require, "tokyonight") then
			require("tokyonight").setup({
				style = detected_bg == "light" and "day" or "night",
				transparent = false,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
				},
			})
			vim.cmd.colorscheme("tokyonight")
		end
	end
end

-- Check theme when nvim gains focus
vim.api.nvim_create_autocmd("FocusGained", {
	desc = "Auto-detect OS theme changes",
	group = vim.api.nvim_create_augroup("theme-sync", { clear = true }),
	callback = reload_theme_if_changed,
})

-- Sync clipboard with OS
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Basic Keymaps
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic quickfix" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus left" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus right" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus down" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus up" })

-- Buffer navigation
vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Terminal
vim.keymap.set("n", "<leader>tt", "<cmd>terminal<CR>", { desc = "Open terminal" })

-- Theme toggle
vim.keymap.set("n", "<leader>tg", function()
	vim.opt.background = vim.opt.background:get() == "dark" and "light" or "dark"
end, { desc = "Toggle theme" })

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Install lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Plugin configuration
require("lazy").setup({
	-- Essential plugins only
	"tpope/vim-sleuth",

	-- BufferLine for tabs
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					diagnostics = "nvim_lsp",
					offsets = {
						{
							filetype = "NvimTree",
							text = "File Explorer",
							text_align = "center",
							separator = true,
						},
					},
					separator_style = "thin",
					always_show_bufferline = true,
				},
			})
		end,
	},

	-- Git integration
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "G" },
		keys = {
			{ "<leader>gs", "<cmd>Git<CR>", desc = "[G]it [S]tatus" },
			{ "<leader>gc", "<cmd>Git commit<CR>", desc = "[G]it [C]ommit" },
			{ "<leader>gp", "<cmd>Git push<CR>", desc = "[G]it [P]ush" },
			{ "<leader>gl", "<cmd>Git pull<CR>", desc = "[G]it Pul[l]" },
		},
	},

	{
		"kdheepak/lazygit.nvim",
		cmd = "LazyGit",
		keys = {
			{ "<leader>gg", "<cmd>LazyGit<CR>", desc = "Lazy[G]it" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")
				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				-- Navigation
				map("n", "]c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "]c", bang = true })
					else
						gitsigns.nav_hunk("next")
					end
				end, { desc = "Next git change" })

				map("n", "[c", function()
					if vim.wo.diff then
						vim.cmd.normal({ "[c", bang = true })
					else
						gitsigns.nav_hunk("prev")
					end
				end, { desc = "Previous git change" })

				-- Actions
				map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "Stage hunk" })
				map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "Reset hunk" })
				map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
				map("n", "<leader>hb", gitsigns.blame_line, { desc = "Blame line" })
			end,
		},
	},

	-- File explorer
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
		},
		opts = {
			update_focused_file = { enable = true },
			renderer = { group_empty = true, indent_markers = { enable = true } },
			view = { width = 30 },
			actions = { open_file = { resize_window = true } },
		},
	},

	-- Which-key for keybinding help
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			icons = { mappings = vim.g.have_nerd_font },
			spec = {
				{ "<leader>c", group = "[C]ode", mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
				{ "<leader>g", group = "[G]it" },
			},
		},
	},

	-- Fuzzy finder
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		event = "VimEnter",
		config = function()
			local fzf = require("fzf-lua")

			fzf.setup({
				fzf_colors = true,
				winopts = {
					height = 0.85,
					width = 0.80,
					preview = {
						default = "bat",
						layout = "flex",
						flip_columns = 100,
					},
				},
				files = {
					fd_opts = "--color=never --hidden --type f --type l"
						.. " --exclude .git"
						.. " --exclude node_modules"
						.. " --exclude dist"
						.. " --exclude build"
						.. " --exclude target"
						.. " --exclude vendor",
				},
				grep = {
					rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 -e",
					rg_glob = true,
					hidden = false,
				},
			})

			fzf.register_ui_select()

			-- Keymaps
			vim.keymap.set("n", "<leader>sh", fzf.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sk", fzf.keymaps, { desc = "[S]earch [K]eymaps" })
			vim.keymap.set("n", "<leader>sf", fzf.files, { desc = "[S]earch [F]iles" })
			vim.keymap.set("n", "<leader>sw", fzf.grep_cword, { desc = "[S]earch [W]ord" })
			vim.keymap.set("n", "<leader>sg", fzf.live_grep, { desc = "[S]earch by [G]rep" })
			vim.keymap.set("n", "<leader>sd", fzf.diagnostics_workspace, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sr", fzf.resume, { desc = "[S]earch [R]esume last" })
			vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "Find buffers" })

			-- Search Neovim config files
			vim.keymap.set("n", "<leader>sn", function()
				fzf.files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- LSP Configuration
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(event)
					local fzf = require("fzf-lua")
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("gd", fzf.lsp_definitions, "[G]oto [D]efinition")
					map("gr", fzf.lsp_references, "[G]oto [R]eferences")
					map("gi", fzf.lsp_implementations, "[G]oto [I]mplementation")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ca", fzf.lsp_code_actions, "[C]ode [A]ction")
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
						},
					},
				},
			}

			require("mason").setup()
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, { "stylua" })
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},

	-- Autoformatting
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				return {
					timeout_ms = 500,
					lsp_format = "fallback",
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
			},
		},
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = { completeopt = "menu,menuone,noinsert" },
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<C-Space>"] = cmp.mapping.complete({}),
				}),
				sources = {
					{ name = "lazydev", group_index = 0 },
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				},
			})
		end,
	},

	-- Simple, fast theme
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = vim.opt.background:get() == "light" and "day" or "night",
				transparent = false,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
				},
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- Mini plugins (lightweight alternatives)
	{
		"echasnovski/mini.nvim",
		config = function()
			require("mini.ai").setup({ n_lines = 500 })
			require("mini.surround").setup()
			require("mini.pairs").setup()

			-- Simple statusline
			local statusline = require("mini.statusline")
			statusline.setup({ use_icons = vim.g.have_nerd_font })
			statusline.section_location = function()
				return "%2l:%-2v"
			end
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"vim",
				"vimdoc",
				"javascript",
				"typescript",
				"json",
				"python",
				"css",
				"go",
				"elixir",
			},
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true, disable = { "ruby" } },
		},
	},
}, {
	-- Lazy.nvim options
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	ui = {
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
