local M = {
	'nvim-tree/nvim-tree.lua',
	lazy = false,
	keys = {
		{ '<C-b>', ':NvimTreeToggle<CR>' },
	},
	dependencies = {
		{ 'nvim-tree/nvim-web-devicons' },
	},
	config = function()
		-- disable netrw at the very start of your init.lua
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- optionally enable 24-bit colour
		vim.opt.termguicolors = true

		local function on_attach(bufnr)
			local api = require('nvim-tree.api')
			local function opts(desc)
				return {
					desc = 'nvim-tree: ' .. desc,
					buffer = bufnr,
					noremap = true,
					silent = true,
					nowait = true,
				}
			end

			api.config.mappings.default_on_attach(bufnr)
			vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
			vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open Horizontal Split'))
			vim.keymap.set('n', 'i', api.node.open.vertical, opts('Open Vertical Split'))
		end

		require('nvim-web-devicons').setup()

		require('nvim-tree').setup({
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
			update_focused_file = {
				enable = true,
			},
			on_attach = on_attach,
		})
	end,
}

return M
