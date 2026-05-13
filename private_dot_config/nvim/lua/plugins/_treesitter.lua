-- nvim-treesitter `main` branch (the legacy `master` branch was archived in 2025).
--
-- REQUIRES the `tree-sitter` CLI on PATH (Arch: `pacman -S tree-sitter-cli`,
-- macOS: `brew install tree-sitter-cli`). The `main` branch always compiles parsers
-- locally — no pre-built fallback like the `master` branch had.
--
-- The `main` branch removed `require('nvim-treesitter.configs').setup{}`. Parsers
-- are installed via `require('nvim-treesitter').install{}`; highlight / indent /
-- folds are enabled per-buffer in a `FileType` autocmd. Sub-modules that lived in
-- the old `configs` table (incremental_selection, textsubjects, tree_docs,
-- refactor, ...) no longer exist — see the TODO at the bottom of this file for
-- replacements that still need to be wired up.

local ensure_installed = {
	'bash',
	'c',
	'css',
	'go',
	'html',
	'javascript',
	'json',
	'lua',
	'markdown',
	'markdown_inline',
	'python',
	'query',
	'regex',
	'rust',
	'scss',
	'toml',
	'tsx',
	'typescript',
	'vim',
	'vimdoc',
	'vue',
	'yaml',
}

return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false,
		build = ':TSUpdate',
		config = function()
			-- Skip install on machines without the tree-sitter CLI.
			-- Neovim ships bundled parsers for c/lua/vim/vimdoc/query/markdown/markdown_inline,
			-- so highlight for those still works; only non-bundled languages are affected.
			if vim.fn.executable('tree-sitter') == 1 then
				require('nvim-treesitter').install(ensure_installed)
			else
				vim.schedule(function()
					vim.notify(
						'[nvim-treesitter] `tree-sitter` CLI not found — non-bundled parsers will not be installed.\n' ..
						'  Arch:  sudo pacman -S tree-sitter-cli\n' ..
						'  macOS: brew install tree-sitter-cli',
						vim.log.levels.WARN
					)
				end)
			end

			-- Returns true if treesitter highlight + indent + folds were enabled.
			-- `vim.treesitter.start` is the real probe — `vim.treesitter.language.add`
			-- returns true whenever the language has any runtime files (queries),
			-- even if the parser .so is missing.
			local function try_enable(buf, lang)
				if not pcall(vim.treesitter.start, buf, lang) then
					return false
				end
				vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
				vim.wo.foldmethod = 'expr'
				return true
			end

			vim.api.nvim_create_autocmd('FileType', {
				group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
				callback = function(ev)
					local ft = vim.bo[ev.buf].filetype
					local lang = vim.treesitter.language.get_lang(ft) or ft
					if not lang or lang == '' then return end

					if try_enable(ev.buf, lang) then return end

					-- Parser not yet installed. On-demand install (replaces master's
					-- `auto_install = true`) so opening a new filetype Just Works.
					if vim.fn.executable('tree-sitter') ~= 1 then return end
					if not vim.list_contains(require('nvim-treesitter.config').get_available(), lang) then return end

					require('nvim-treesitter').install(lang):await(function()
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(ev.buf) then
								try_enable(ev.buf, lang)
							end
						end)
					end)
				end,
			})
		end,
	},

	{
		'nvim-treesitter/nvim-treesitter-textobjects',
		branch = 'main',
		dependencies = { 'nvim-treesitter/nvim-treesitter' },
		event = { 'BufReadPost', 'BufNewFile' },
		config = function()
			local select = require('nvim-treesitter-textobjects.select')
			local move = require('nvim-treesitter-textobjects.move')

			-- selection (visual / operator-pending)
			local sel = function(query, group)
				return function()
					select.select_textobject(query, group or 'textobjects')
				end
			end
			vim.keymap.set({ 'x', 'o' }, 'af', sel('@function.outer'), { desc = 'a function' })
			vim.keymap.set({ 'x', 'o' }, 'if', sel('@function.inner'), { desc = 'inner function' })
			vim.keymap.set({ 'x', 'o' }, 'ac', sel('@class.outer'),    { desc = 'a class' })
			vim.keymap.set({ 'x', 'o' }, 'ic', sel('@class.inner'),    { desc = 'inner class' })
			vim.keymap.set({ 'x', 'o' }, 'as', sel('@scope', 'locals'), { desc = 'language scope' })

			-- movement
			vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() move.goto_next_start('@function.outer') end, { desc = 'next function start' })
			vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() move.goto_next_end('@function.outer') end,   { desc = 'next function end' })
			vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() move.goto_previous_start('@function.outer') end, { desc = 'prev function start' })
			vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() move.goto_previous_end('@function.outer') end,   { desc = 'prev function end' })

			vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() move.goto_next_start('@class.outer') end, { desc = 'next class start' })
			vim.keymap.set({ 'n', 'x', 'o' }, '][', function() move.goto_next_end('@class.outer') end,   { desc = 'next class end' })
			vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() move.goto_previous_start('@class.outer') end, { desc = 'prev class start' })
			vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() move.goto_previous_end('@class.outer') end,   { desc = 'prev class end' })

			vim.keymap.set({ 'n', 'x', 'o' }, ']o', function() move.goto_next_start('@loop.*') end, { desc = 'next loop' })
			vim.keymap.set({ 'n', 'x', 'o' }, ']d', function() move.goto_next_start('@conditional.outer') end, { desc = 'next conditional' })
			vim.keymap.set({ 'n', 'x', 'o' }, '[d', function() move.goto_previous_start('@conditional.outer') end, { desc = 'prev conditional' })

			vim.keymap.set({ 'n', 'x', 'o' }, ']s', function() move.goto_next_start('@scope', 'locals') end, { desc = 'next scope' })
			vim.keymap.set({ 'n', 'x', 'o' }, ']z', function() move.goto_next_start('@fold', 'folds') end,   { desc = 'next fold' })
		end,
	},

	-- TODO: features dropped along with the master branch — pick replacements when needed.
	--   * incremental_selection  → built-in `vim.treesitter.start`/`vim.treesitter.get_node` based mappings, or `aaronik/treewalker.nvim`
	--   * textsubjects           → `RRethy/nvim-treesitter-textsubjects` once it ships a `main`-compatible release
	--   * tree_docs              → `danymat/neogen` (already pulled in by other plugins) covers most of the use cases
	--   * refactor               → split: highlight_current_scope → built-in LSP / `RRethy/vim-illuminate`; navigation → LSP / `aaronik/treewalker.nvim`
}

