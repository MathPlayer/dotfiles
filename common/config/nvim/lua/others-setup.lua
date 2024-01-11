-- TODO: Update most of the commented out code sice it lives since the init.vim era.

-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
-- Disable folding at startup
-- vim.opt.foldenable = false

-- local ok, navic = pcall(require, 'nvim-navic')
-- if ok then
--   vim.o.winbar="%{%v:lua.require'nvim-navic'.get_location()%}"
-- end

-- [[ mini.trailspace ]]
require('mini.trailspace').setup()

-- if &runtimepath =~ 'vscode.nvim'
--
--   lua << BLOCK
--   vim.opt.background = 'dark'
--   local c = require('vscode.colors')
--   require('vscode').setup({
--     -- Disable nvim-tree background color
--     disable_nvimtree_bg = true,
--
--     -- Override colors (see ./lua/vscode/colors.lua)
--     color_overrides = {
--       vscLineNumber = '#FFFFFF',
--     },
--
--     -- Override highlight groups (see ./lua/vscode/theme.lua)
--     group_overrides = {
--       -- this supports the same val table as vim.api.nvim_set_hl
--       -- use colors from this colorscheme by requiring vscode.colors!
--       Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
--     }
--   })
-- BLOCK
--
-- endif

-- vim: ts=2 sts=2 sw=2 et
