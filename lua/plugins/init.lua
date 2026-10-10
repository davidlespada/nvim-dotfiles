return {

	-- Theme (rich treesitter colors, transparent possible)
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		opts = {
			flavour = "mocha",
			transparent_background = true,
			term_colors = true,
		},
		config = function(_, opts)
			require("catppuccin").setup(opts)
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- Line numbers
	{
		"shrynx/line-numbers.nvim",
		opts = {},
	},

	-- Mini icons
	{ "nvim-mini/mini.icons", version = "*", opts = {} },

	-- Web devicons
	{ "nvim-tree/nvim-web-devicons", version = "*", opts = {} },

	-- which-key
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{ "<leader>b", group = "buffer" },
				{ "<leader>d", group = "diagnostics" },
				{ "<leader>e", group = "explorer" },
				{ "<leader>f", group = "file" },
				{ "<leader>h", group = "help" },
				{ "<leader>n", group = "navigate" },
				{ "<leader>o", group = "toggle" },
				{ "<leader>q", group = "quit/session" },
				{ "<leader>s", group = "search" },
				{ "<leader>t", group = "tab/terminal" },
				{ "<leader>w", group = "window" },
				{ "<leader>x", group = "quickfix/location" },
				{ "<leader>y", group = "clipboard" },
			},
		},
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer local Keymaps (which-key)",
			},
		},
	},

	-- Plenary
	{
		"nvim-lua/plenary.nvim",
		version = "*",
	},

	-- telescope fzf
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install",
	},

	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		version = "*",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {},
		config = function(_, opts)
			require("telescope").setup(opts)
			pcall(require("telescope").load_extension, "fzf")
		end,
	},

	-- Hop
	{
		"wsdjeg/hop.nvim",
		version = "*",
		opts = {
			keys = "etovxqpdygfblzhckisuran",
		},
		config = function(_, opts)
			require("hop").setup(opts)
			-- registers the :HopNodes command (needs a treesitter parser for the buffer)
			pcall(function()
				require("hop-treesitter").register()
			end)
		end,
	},

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").setup({
				install_dir = vim.fn.stdpath("data") .. "/site",
			})
			require("nvim-treesitter").install({ "python", "c", "cpp", "odin" })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python", "c", "cpp", "odin" },
				callback = function()
					vim.treesitter.start()
				end,
			})
		end,
	},

	-- Nui
	{
		"MunifTanjim/nui.nvim",
		version = "*",
	},

	-- neotree
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		cmd = "Neotree",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			close_if_last_window = false,
			popup_border_style = "rounded",
			enable_git_status = true,
			enable_diagnostics = true,
			-- files-only: no winbar selector noise
			source_selector = {
				winbar = false,
				statusline = false,
			},
			filesystem = {
				follow_current_file = { enabled = true },
				hijack_netrw_behavior = "open_default",
				use_libuv_file_watcher = true,
				filtered_items = {
					visible = true,
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
			window = {
				width = 32,
			},
		},
		config = function(_, opts)
			require("neo-tree").setup(opts)
		end,
	},
	{
		"Crysthamus/nvim-file-operations",
		-- branch = "compat" -- if you are on Neovim <= 0.10
		dependencies = {
			"nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
		},
		config = function()
			require("nvim-file-operations").setup()
		end,
	},
	{
		"s1n7ax/nvim-window-picker",
		version = "2.*",
		config = function()
			require("window-picker").setup({
				filter_rules = {
					include_current_win = false,
					autoselect_one = true,
					-- filter using buffer options
					bo = {
						-- if the file type is one of following, the window will be ignored
						filetype = { "neo-tree", "neo-tree-popup", "notify" },
						-- if the buffer type is one of following, the window will be ignored
						buftype = { "terminal", "quickfix" },
					},
				},
			})
		end,
	},

	-- vim-local-history
	{
		"dinhhuy258/vim-local-history",
		version = "*",
	},
	{
		"neovim/nvim-lspconfig",
		version = "*",
	},

	-- formatter
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				format_on_save = {
					timeouts_ms = 500,
					lsp_format = "fallback",
				},
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "isort", "black" },
					cpp = { "clang-format" },
					c = { "clang-format" },
					odin = { "odinfmt" },
				},
			})
		end,
	},
}
