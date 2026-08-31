local M = {
	'dense-analysis/ale', -- check syntax with LSP support
	lazy = false,
}

M.config = function()
	-- lint after 1000ms after changes are made both on insert mode and normal mode
	vim.g.ale_lint_on_text_changed = 'always'
	vim.g.ale_lint_delay = 1000
	-- vim.g.ale_fix_on_save = 1

	-- use nice symbols for errors and warnings
	vim.g.ale_sign_error = '✗ '
	vim.g.ale_sign_warning = '⚠ '

	vim.g.ale_fixers = {
		['*'] = { 'remove_trailing_lines', 'trim_whitespace' },
		javascript = { 'eslint' },
		vue = { 'eslint' },
	}

	vim.g.ale_linters = {
		lua = { 'lua_language_server' },
		-- 只留 `php`（= php -l 純語法檢查），拿掉 phpcs/phpmd 等排版風格 linter
		-- （CI2 老 code 不符 PEAR standard，會整片排版警告）
		-- 語法錯誤：ALE php -l + intelephense LSP 兩層都會報
		php = { 'php' },
	}

	vim.g.ale_linter_aliases = {
		vue = { 'javascript', 'html', 'scss' },
	}
end

return M
