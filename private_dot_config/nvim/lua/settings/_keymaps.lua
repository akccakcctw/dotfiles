local keymap = vim.keymap

-- Key Mappings

-- edit init.lua
keymap.set('n', '<Leader>ee', ':tabe $MYVIMRC<CR>', {silent = true})
keymap.set('n', '<Leader>so', ':tabe $MYVIMRC<CR>', {silent = true})

-- switch to next/previous tab
keymap.set('n', '<Leader>n', ':tabnext<CR>')
keymap.set('n', '<Leader>p', ':tabprevious<CR>')

-- split window
keymap.set('n', '<C-\\>', ':vsp<CR>', {silent = true})

-- split window navigations
keymap.set('n', '<C-Left>', '<C-w>h')
keymap.set('n', '<C-Down>', '<C-w>j')
keymap.set('n', '<C-Up>', '<C-w>k')
keymap.set('n', '<C-Right>', '<C-w>l')

-- switch between vertical/horizontal split
keymap.set('n', '<Leader>E', ':windo wincmd K<CR>')
keymap.set('n', '<Leader>I', ':windo wincmd H<CR>')

-- no highlight search result
keymap.set('n', '<Leader>/', ':nohl<CR>')

-- toggle wrap
keymap.set('n', '<F2>', ':set wrap! wrap?<CR>')

-- increase and decrease number under the cursor
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- move text with CTRL+[jk]
keymap.set('n', '<C-j>', ':m+<CR>:echo "move line down"<CR>', {silent = true})
keymap.set('n', '<C-k>', ':m-2<CR>:echo "move line up"<CR>', {silent = true})
keymap.set('v', '<C-j>', ":m'>+<CR>:echo 'move block down'<CR>", {silent = true})
keymap.set('v', '<C-k>', ":m'<-2<CR>:echo 'move block up'<CR>", {silent = true})

-- avoid the escape key
keymap.set('i', 'jj', '<Esc>')

-- fix syntax highlighting
keymap.set('n', '<F12>', '<Esc>:syntax sync fromstart<CR>')
keymap.set('i', '<F12>', '<C-o>:syntax sync fromstart<CR>')

-- exit terminal mode
keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- strip trailing whitespace (,ss)
local function strip_whitespace()
	local save_cursor = vim.fn.getpos(".")
	local old_query = vim.fn.getreg('/')
	vim.cmd([[%s/\s\+$//e]])
	vim.fn.setpos('.', save_cursor)
	vim.fn.setreg('/', old_query)
end
keymap.set('n', '<Leader>ss', strip_whitespace, {silent = true, noremap = true})

-- save a file as root (,WW)
keymap.set('n', '<Leader>WW', ':w !sudo tee % > /dev/null<CR>', {silent = true, noremap = true})

-- emmet-vim
vim.g.user_emmet_leader_key = '<C-e>'
-- vim.g.user_emmet_expandabbr_key = '<Leader>'
vim.g.user_emmet_mode = 'in' -- only enable in Input/Normal mode
vim.g.user_emmet_install_global = 0 -- enable just for HTML/CSS
vim.g.user_emmet_settings = {
	javascript = {
		extends = 'jsx',
	},
}
vim.api.nvim_create_autocmd('filetype', {
	pattern = { 'html', 'css', 'scss', 'pug', 'vue', 'php', 'javascript' },
	command = 'EmmetInstall',
})

-- Indent Guildes
vim.cmd [[
	let g:indent_guides_start_level = 2
	let g:indent_guides_auto_colors = 0
	let g:indent_guides_default_mapping = 0 " (toggle IndentGuides with <Leader>ig)
	autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=black ctermbg=black
	autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=green ctermbg=233
]]
