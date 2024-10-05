local M = {
	'williamboman/mason.nvim', -- language server manager for neovim
	lazy = false,
	dependencies = {
		{
			'jay-babu/mason-nvim-dap.nvim',
			dependencies = {
				'rcarriga/nvim-dap-ui', -- provides UI for debugging
				dependencies = {
					'mfussenegger/nvim-dap',
					'nvim-neotest/nvim-nio',
				},
			},
		},
		'williamboman/mason-lspconfig.nvim',
		'neovim/nvim-lspconfig', -- attach client to neovim
		-- ref: https://zhuanlan.zhihu.com/p/643033884
		{
			'hrsh7th/nvim-cmp', -- auto-completion engine
			dependencies = {
				'hrsh7th/cmp-nvim-lsp',
				'hrsh7th/cmp-buffer',
				'hrsh7th/cmp-path',
				'hrsh7th/cmp-cmdline',

				'L3MON4D3/LuaSnip',
				'saadparwaiz1/cmp_luasnip',

				'rafamadriz/friendly-snippets',
				'onsails/lspkind-nvim',
			},
		},
	},
}

M.config = function()
	require('mason').setup({
		ui = {
			icons = {
				package_installed = "✓",
				package_pending = "➜",
				package_uninstalled = "✗",
			},
			border = 'rounded',
		},
	})

	-- dapui (provides UI for debugging)
	require('dapui').setup()
	local dap, dapui = require('dap'), require('dapui')
	dap.listeners.before.attach.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.launch.dapui_config = function()
		dapui.open()
	end
	dap.listeners.before.event_terminated.dapui_config = function()
		dapui.close()
	end
	dap.listeners.before.event_exited.dapui_config = function()
		dapui.close()
	end

	require('mason-nvim-dap').setup({
		automatic_installation = true,

		-- Makes a best effort to setup the various debuggers with
		-- reasonable debug configurations
		automatic_setup = true,

		-- You can provide additional configuration to the handlers,
		-- see mason-nvim-dap README for more information
		handlers = {
			function(config)
				require('mason-nvim-dap').default_setup(config)
			end,
			php = function(config)
				config.configurations = {
					{
						type = 'php',
						request = 'launch',
						name = 'Listen for Xdebug',
						port = 9003,
						log = true,
						program = "${file}",
						pathMappings = {
							['/var/www/kkday-member-ci'] = vim.fn.getcwd() .. '/',
						},
						hostname = '0.0.0.0',
					}
				}
				require('mason-nvim-dap').default_setup(config) -- don't forget this!
			end,
		},
		-- You'll need to check that you have the required things installed
		-- online, please don't ask me how to install them :)
		ensure_installed = {
			-- Update this to ensure that you have the debuggers for the langs you want
			-- 'delve',
		},
	})
	require('mason-lspconfig').setup({
		ensure_installed = {
			'bashls',
			'cssls',
			'emmet_ls',
			'html',
			'intelephense',
			'lua_ls',
			'rust_analyzer',
			'ts_ls',
			'vuels',
			'yamlls',
		}
	})
	require('mason-lspconfig').setup_handlers({
		-- workaround: rename "tsserver" to "ts_ls"
		-- https://github.com/neovim/nvim-lspconfig/pull/3232#issuecomment-2331025714
		function(server_name) -- default handler (optional)
			if server_name == "tsserver" then
				server_name = "ts_ls"
			end
		end,
	})

	-- Set different settings for different languages' LSP
	-- LSP list: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	-- How to use setup({}): https://github.com/neovim/nvim-lspconfig/wiki/Understanding-setup-%7B%7D
	--     - the settings table is sent to the LSP
	--     - on_attach: a lua callback function to run after LSP atteches to a given buffer
	local lspconfig = require('lspconfig')

	-- Customized on_attach function
	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	local opts = { noremap = true, silent = true }
	vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
	vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

	-- Use an on_attach function to only map the following keys
	-- after the language server attaches to the current buffer
	local on_attach = function(client, bufnr)
		-- Enable completion triggered by <c-x><c-o>
		vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local bufopts = { noremap = true, silent = true, buffer = bufnr }
		vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
		vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
		-- vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
		vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
		vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
		vim.keymap.set('n', '<space>wl', function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, bufopts)
		vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
		vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
		vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
		vim.keymap.set('n', '<space>f', function()
			vim.lsp.buf.format({ async = true })
		end, bufopts)
	end

	-- Configure each language
	-- How to add LSP for a specific language?
	-- 1. use `:Mason` to install corresponding LSP
	-- 2. add configuration below

	lspconfig.vuels.setup({
		on_attach = on_attach,
	})
	lspconfig.intelephense.setup({
		on_attach = on_attach,
	})
	lspconfig.ts_ls.setup({
		on_attach = on_attach,
	})
	lspconfig.lua_ls.setup({
		on_attach = on_attach,
	})
	lspconfig.bashls.setup({
		on_attach = on_attach,
	})
	lspconfig.cssls.setup({
		on_attach = on_attach,
	})
	lspconfig.astro.setup({
		on_attach = on_attach,
	})
	lspconfig.tailwindcss.setup({
		on_attach = on_attach,
	})

	-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
	-- local capabilities = vim.lsp.protocol.make_client_capabilities()
	-- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

	-- nvim-cmp
	local cmp = require("cmp")
	vim.opt.completeopt = "menu,menuone,noselect"

	cmp.setup({
		snippet = {
			expand = function(args)
				-- following plugin is required
				-- { 'L3MON4D3/LuaSnip' },
				-- { 'saadparwaiz1/cmp_luasnip' },
				require('luasnip').lsp_expand(args.body)
			end,
		},
		window = {
      -- completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
		mapping = cmp.mapping.preset.insert({
			['<C-d>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			-- ['<C-k>'] = cmp.mapping.complete(),
			['<C-e>'] = cmp.mapping.abort(),
			['<C-k>'] = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Replace,
				select = true,
			}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			['<CR>'] = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Replace,
				select = true,
			}), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
			['<Tab>'] = cmp.mapping.select_next_item(),
			['<S-Tab>'] = cmp.mapping.select_prev_item(),
		}),
		-- show icon with "lspkind-nvim"
		formatting = {
			format = require('lspkind').cmp_format({
				mode = 'symbol',
				with_text = true, -- do not show text alongside icons
				maxwidth = 50,    -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
				before = function(entry, vim_item)
					vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
					return vim_item
				end
			})
		},
		sources = cmp.config.sources({
			-- order is matter
			{ name = 'nvim_lsp' },
			{ name = 'luasnip' },
			{ name = 'buffer' },
			{ name = 'path' },
			{ name = 'supermaven' },
		}),
	})

	-- load vscode snippet (friendly-snippet)
	require("luasnip.loaders.from_vscode").lazy_load()

end

return M
