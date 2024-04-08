local opt = vim.opt
local options = safe_require('libraries._set_options')

if not options then
	return
end

options.set_scoped_options('g', {
	mapleader = ',',
	maplocalleader = ',',
})
