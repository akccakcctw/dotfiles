local M = {}

function M.set_scoped_options(locality, options)
	local scopes = { o = vim.o, b = vim.bo, g = vim.g, w = vim.wo }
	local scope = scopes[locality]
	for key, value in pairs(options) do
		scope[key] = value
	end
end

return M
