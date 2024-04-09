local M = {
	'vim-airline/vim-airline',
	lazy = false,
	priority = 1000,
	dependencies = {
		-- 'vim-airline/vim-airline-themes',
		-- 'ryanoasis/vim-devicons',
		'jacoborus/tender',
	},
}

M.config = function()
	vim.g.airline_powerline_fonts = 1
	vim.g.airline_theme = 'tender'
	vim.g['airline#extensions#whitespace#enabled'] = 0

	-- enable tender airline theme
	vim.g.tender_airline = 1
end

return M
