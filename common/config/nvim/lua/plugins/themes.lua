return {
  -- NOTE: colorschemes are loaded early, as instructed in first example at
  -- https://github.com/folke/lazy.nvim/blob/main/README.md?plain=1#L201
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- load the colorscheme here
      -- vim.cmd.colorscheme 'tokyonight'
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- load the colorscheme here
      -- vim.cmd.colorscheme 'gruvbox'
      -- vim.g.gitgutter_override_sign_column_highlight=1
    end,
  },
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- load the colorscheme here
      vim.cmd.colorscheme 'onedark'
    end,
  },
}
