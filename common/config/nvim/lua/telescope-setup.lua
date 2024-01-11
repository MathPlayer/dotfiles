local map = require('utils').map

local tb = require('telescope.builtin')
map('n', '<leader>?', tb.oldfiles, '[telescope] Find recently opened files')
map('n', '<leader>b', tb.buffers, '[telescope] Find existing [b]uffers')
map('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  tb.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, '[telescope] Fuzzily search in current buffer')

map('n', '<leader>tgf', tb.git_files, '[Telescope] Search git files')
map('n', '<leader>tf', tb.find_files, '[S]earch [F]iles')
map('n', '<leader>th', tb.help_tags, '[S]earch [H]elp')
map('n', '<leader>tw', tb.grep_string, '[S]earch current [W]ord')
map('n', '<leader>tg', tb.live_grep, '[S]earch by [G]rep')
map('n', '<leader>td', tb.diagnostics, '[S]earch [D]iagnostics')

-- vim: ts=2 sts=2 sw=2 et
