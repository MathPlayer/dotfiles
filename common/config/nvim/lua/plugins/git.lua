return {
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-rhubarb' },
  {
    'junegunn/gv.vim',
    dependencies = {
      'tpope/vim-fugitive',
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      -- NOTE: copied from kickstart.nvim
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      -- Copied from https://github.com/lewis6991/gitsigns.nvim#keymaps
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = require('utils').map

        local function buf_map(mode, keys, func, desc)
          map(mode, keys, func, desc, { buffer = bufnr })
        end

        -- Actions
        buf_map({'n', 'v'}, '<leader>gs', gs.stage_hunk, 'Stage hunk')
        buf_map({'n', 'v'}, '<leader>gr', gs.reset_hunk, 'Reset hunk')
        buf_map({'n', 'v'}, '<leader>grs', gs.undo_stage_hunk, '[Git] Reset Staged hunk (e.g. unstage)')
        buf_map('n', '<leader>gS', gs.stage_buffer, '[Git] Stage buffer')
        buf_map('n', '<leader>gR', gs.reset_buffer, '[Git] Reset buffer')
        buf_map('n', '<leader>gp', gs.prev_hunk, '[Git] go to Previous hunk')
        buf_map('n', '<leader>gn', gs.next_hunk, '[Git] go to Next hunk')
        buf_map('n', '<leader>gph', gs.preview_hunk, '[Git] Preview Hunk')
        buf_map('n', '<leader>gb', function() gs.blame_line{full=true} end, '[Git] Blame')
        buf_map('n', '<leader>gbt', gs.toggle_current_line_blame, '[Git] Blame Toggle current line')
        buf_map('n', '<leader>gd', gs.diffthis, '[Git] Diff this')
        buf_map('n', '<leader>gD', function() gs.diffthis('~') end, '[Git] Diff this ~')
        buf_map('n', '<leader>gt', gs.toggle_deleted, '[Git] Toggle deleted')

        -- Text object
        buf_map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', '[Git] select hunk')
      end
    }
  },
}
