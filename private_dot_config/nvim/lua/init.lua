-- ref: https://github.com/beauwilliams/Dotfiles/tree/master/Vim/nvim
-- ref: https://github.com/milanglacier/nvim

local function init()
	vim.loader.enable() -- speed up loading lua modules in neovim to improve startup time
	require("libraries._module")
	safe_require("settings._map_leader")
	safe_require("plugins._init")
	safe_require("settings._keymaps")
	safe_require("settings._commands")
	safe_require("settings._options")
	return nil
end

init()
return nil
