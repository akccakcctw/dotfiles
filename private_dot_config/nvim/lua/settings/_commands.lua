local cmd = vim.cmd

-- EslintFix command
cmd([[command EslintFix execute '!npx eslint % --fix']])

-- StylelintFix command
cmd([[command StylelintFix execute '!npx stylelint % --fix']])

-- Autoread while file change
cmd([[au FocusGained,BufEnter * :checktime]])
