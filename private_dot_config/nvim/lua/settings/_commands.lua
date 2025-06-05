local cmd = vim.cmd

-- Autoread while file change
cmd([[au FocusGained,BufEnter * :checktime]])

local api = vim.api
local fn = vim.fn

---@param bin_name string The name of the binary to search for
---@return string|nil Full path to the binary or nil if not found
local function get_local_bin(bin_name)
  local cwd = fn.getcwd()
  local paths_checked = {}

  -- 1. local binary
  local local_bin = cwd .. '/node_modules/.bin/' .. bin_name
  table.insert(paths_checked, local_bin)
  if fn.filereadable(local_bin) == 1 then
    return local_bin
  end

  -- 2. global node_modules binary (npm prefix -g)
  local ok, global_prefix = pcall(fn.system, { "npm", "prefix", "-g" })
  if ok and type(global_prefix) == "string" then
    global_prefix = global_prefix:gsub("\n", "") -- 去除換行
    local global_bin = global_prefix .. '/node_modules/.bin/' .. bin_name
    table.insert(paths_checked, global_bin)
    if fn.filereadable(global_bin) == 1 then
      return global_bin
    end
  end

  -- 3. 可執行的 bin（在 PATH）
  if fn.executable(bin_name) == 1 then
    return bin_name
  end

  -- 4. 找不到，顯示錯誤與檢查過的路徑
  vim.notify(
    ("Cannot find '%s'. Tried paths:\n%s"):format(
      bin_name,
      table.concat(paths_checked, "\n")
    ),
    vim.log.levels.ERROR
  )

  return nil
end

---@param command_name string like "EslintFix"
---@param bin_name string like "eslint"
---@param emoji string emoji shown in notification messages
---@return nil
local function create_linter_fix_command(command_name, bin_name, emoji)
  api.nvim_create_user_command(command_name, function()
    local filepath = fn.expand('%:p')
    local bin_path = get_local_bin(bin_name)

    if not bin_path then return end

    local msg = string.format('%s 正在執行 %s 修復: %s', emoji, bin_name, filepath)
    vim.notify(msg, vim.log.levels.INFO)

    local fix_cmd = string.format('%s "%s" --fix', bin_path, filepath)
    local output = fn.system(fix_cmd)
    local exit_code = vim.v.shell_error

    if exit_code == 0 then
      vim.cmd('edit') -- reload buffer
      vim.notify(string.format('✅ %s 修復完成，內容已重新載入', bin_name), vim.log.levels.INFO)
    else
      vim.notify(string.format('⚠️ %s 修復過程中發生錯誤，請查看輸出內容', bin_name), vim.log.levels.WARN)
      vim.notify(output, vim.log.levels.DEBUG)
    end
  end, {})
end

create_linter_fix_command('EslintFix', 'eslint', '🔧')
create_linter_fix_command('StylelintFix', 'stylelint', '🎨')
create_linter_fix_command('PrettierFix', 'prettier', '💅')
