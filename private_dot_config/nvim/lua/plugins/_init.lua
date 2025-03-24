-- default "~/.local/share/nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local lazy_plugins = {
	{
		safe_require('plugins._nvim_tree'),
	},

	-- syntax
	{
		'alker0/chezmoi.vim',
		lazy = false,
		init = function()
			vim.g['chezmoi#use_tmp_buffer'] = true
		end,
	},
	{
		'amadeus/vim-mjml',
		ft = { 'mjml' },
	},
	{ 'editorconfig/editorconfig-vim' },

	-- git
	{
		'airblade/vim-gitgutter',
		event = 'BufWinEnter',
	},
	{
		'junegunn/gv.vim', -- Git commit browser
		event = 'BufWinEnter',
	},
	{
		'tpope/vim-fugitive', -- Git wrapper
		event = 'BufWinEnter',
	},

	-- treesitter
	{
		safe_require('plugins._treesitter'),
	},
	{
		'danymat/neogen', -- annotation generator
		lazy = false,
		config = function()
			require('neogen').setup {
				enabled = true,
				languages = {
					javascript = {
						template = {
							annotation_convention = 'jsdoc',
						},
					},
					typescript = {
						template = {
							annotation_convention = 'tsdoc',
						},
					},
					php = {
						template = {
							annotation_convention = 'phpdoc',
						},
					},
				}
			}

			local opts = { noremap = true, silent = true }
			-- vim.api.nvim_set_keymap("n", "<Leader>nf", ":lua require('neogen').generate({ type = 'func' })<CR>", opts)
			vim.api.nvim_set_keymap("n", "<Leader>nf", ":lua require('neogen').generate()<CR>", opts)
		end,
	},
	{
		'numToStr/Comment.nvim',
		opts = {
			-- pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
			ignore = '^$',
			toggler = {
				line = '<Leader>cc',
				block = '<Leader>c<Space>',
			},
			---LHS of operator-pending mappings in NORMAL and VISUAL mode
			opleader = {
				line = '<Leader>cc',
				block = '<Leader>c<Space>',
			},
			extra = {
				above = '<Leader>cO',
				below = '<Leader>co',
				eol = '<Leader>cA',
			},
		},
		lazy = false,
	},
	{ 'JoosepAlviste/nvim-ts-context-commentstring' },

	-- LSP
	{
		safe_require('plugins._ale'),
	},
	{
		safe_require('plugins._mason'),
	},

	-- fuzzy finder for file search
	{ 'nvim-lua/plenary.nvim' },
	{ 'nvim-telescope/telescope.nvim' },

	-- colorscheme
	{ 'tomasiser/vim-code-dark'},

	-- AI
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		lazy = false,
		version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
		-- config = function()
		-- 	require("copilot").setup({})
		-- end,
		opts = {
			-- add any opts here:
			-- @see https://github.com/yetone/avante.nvim#default-setup-configuration
			-- @see https://github.com/yetone/avante.nvim/blob/main/lua/avante/config.lua
			mappings = {
				ask = "<Leader>ma", -- show sidebar
				edit = "<Leader>me", -- edit selected blocks
				refresh = "<Leader>mr", -- refresh sidebar
				focus = "<Leader>mf", -- switch sidebar focus
				stop = "<Leader>mS",
				select_model = "<Leader>m?", -- select model command
				select_history = "<Leader>mh", -- select history command

				toggle = {
					default = "<Leader>mt", -- toggle sidebar visibility
					debug = "<Leader>md",
					hint = "<Leader>mh",
					suggestion = "<Leader>ms",
					repomap = "<Leader>mR",
				},
				files = {
					add_current = "<Leader>mc", -- Add current buffer to selected files
				},
			},
			provider = "copilot", -- claude, openai, copilot, ...
			copilot = {
				endpoint = "https://api.githubcopilot.com",
				model = "gpt-4o-2024-08-06", -- ["claude-3-5-sonnet-20241022"|"gpt-4o-2024-08-06"]
				proxy = nil, -- [protocol://]host[:port] Use this proxy
				allow_insecure = false, -- Allow insecure server connections
				timeout = 30000, -- Timeout in milliseconds
				temperature = 0,
				max_tokens = 4096,
			},
			-- provider = "claude",
			-- claude = {
			-- 	endpoint = "https://api.anthropic.com",
			-- 	model = "claude-3-5-sonnet-20241022",
			-- 	temperature = 0,
			-- 	max_tokens = 4096,
			-- },
			suggestion = {
				debounce = 600,
				throttle = 600,
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
				'MeanderingProgrammer/render-markdown.nvim',
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	{
		'jackMort/ChatGPT.nvim',
		event = 'VeryLazy',
		config = function()
			require('chatgpt').setup()
		end,
		dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
		},
	},
	{
		'supermaven-inc/supermaven-nvim',
		event = 'VeryLazy',
		config = function()
			require('supermaven-nvim').setup({
				disable_inline_completion = true, -- disables inline completion for use with cmp
			})
		end,
	},

	-- uncategorized
	{ 'Chiel92/vim-autoformat' },
	{ 'Yggdroot/indentLine' },
	{ 'codegram/vim-codereview' }, -- GitHub PR Code Review
	{ 'honza/vim-snippets' },
	{ 'htacg/tidy-html5' },
	{
		'dhruvasagar/vim-table-mode',
		ft = { 'markdown', 'txt' },
		config = function()
			vim.cmd [[
				function! s:isAtStartOfLine(mapping)
					let text_before_cursor = getline('.')[0 : col('.')-1]
					let mapping_pattern = '\V' . escape(a:mapping, '\')
					let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
					return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
				endfunction

				inoreabbrev <expr> <bar><bar>
					\ exists(':TableModeEnable') && <SID>isAtStartOfLine('\|\|') ?
					\ '<c-o>:TableModeEnable<cr><bar><space><bar><left><left>' : '<bar><bar>'
				inoreabbrev <expr> __
					\ exists(':TableModeDisable') && <SID>isAtStartOfLine('__') ?
					\ '<c-o>:silent! TableModeDisable<cr>' : '__'

				" For Markdown-compatible tables
				let g:table_mode_corner = '|'
			]]
		end,
	},
	{
		'iamcco/markdown-preview.nvim',
		ft = { 'markdown' },
		cmd = {
			'MarkdownPreview',
			'MarkdownPreviewToggle',
			'MarkdownPreviewStop',
		},
		build = function() vim.fn['mkdp#util#install']() end,
	},
	{ 'jeetsukumaran/vim-buffergator' },
	{
		'junegunn/fzf',
		name = 'fzf',
		dir = '~/.fzf',
		build = './install --all',
		lazy = false,
	},
	{
		'junegunn/fzf.vim',
		cmd = { 'GFiles', 'Files' },
		keys = {
			{ '<Leader>f', ':GFiles<CR>' },
			{ '<Leader>F', ':Files<CR>' },
			{ '<Leader>l', ':BLines<CR>' },
			{ '<Leader>L', ':Lines<CR>' },
			{ '<Leader>a', ':Rg<Space>' },
		},
	},
	{ 'junegunn/vim-easy-align' },
	{ 'junkblocker/patchreview-vim' }, -- GitHub PR Code Review
	{
		'preservim/tagbar',
		cmd = { 'TagbarToggle' },
		keys = {
			{ '<F8>', ':TagbarToggle' },
		},
	},
	{
		'mattn/emmet-vim',
		ft = { 'html', 'css', 'scss', 'pug', 'vue', 'php', 'javascript', 'astro' },
	},
	{ 'maxmellon/vim-jsx-pretty' },
	{ 'preservim/vim-indent-guides' },
	{ 'szw/vim-tags' },
	{ 'terryma/vim-multiple-cursors' },
	{ 'tpope/vim-surround', lazy = false },
	{
		safe_require('plugins._vim_airline'),
	},
	{ 'wesQ3/vim-windowswap' },
	{
		'yardnsm/vim-import-cost',
		cmd = 'ImportCost',
		build = 'npm install',
	},
	{
		'folke/neodev.nvim', -- for neovim development
		lazy = false,
		opts = {},
	},
}

require('lazy').setup(lazy_plugins, {
	defaults = {
		lazy = true,
	},
})
