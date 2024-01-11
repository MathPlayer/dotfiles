local map = require('utils').map

-- Global key mappings
map('n', ';', ':', 'More efficient command calling via :')
map('c', 'w!!', ' w !sudo tee % >/dev/null', 'Write a file with sudo')
map('n', '-', '@="ddp"<cr>', 'Move a line up; can be used with numbers')
map('n', '_', '@="ddkP"<cr>', 'Move a line down; can be used with numbers')
map('n', '<leader>"', 'viw<esc>a"<esc>hbi"<esc>lel', 'Surround a word by double quotes')
map('n', "<leader>'", "viw<esc>a'<esc>hbi'<esc>lel", 'Surround a word by single quotes')
map('n', 'H', '^', 'Go to beggining of the current line')
map('n', 'L', '$', 'Go to the end of the current line')

map('n', '*', '*zz', 'Search and center screen')

-- See `:help vim.diagnostic.*` for documentation on any of the below functions
map('n', '<leader>e', vim.diagnostic.open_float, 'Open floating diagnostic message')
map('n', '[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic message')
map('n', ']d', vim.diagnostic.goto_next, 'Go to next diagnostic message')
-- map('n', '<leader>q', vim.diagnostic.setloclist, 'Open diagnostics list')
-- TODO: understand their meaning
map('n', '<leader>aa', vim.diagnostic.setqflist, 'Open quickfix list')
map('n', '<leader>ae', function() vim.diagnostic.setqflist({ severity = 'E' }) end, 'Open errors in quickfix list')
map('n', '<leader>aw', function() vim.diagnostic.setqflist({ severity = 'W' }) end, 'Open warnings in quickfix list')

-- Taken from https://stackoverflow.com/a/657457/1549098
map('n', '<leader><cr>', '<cmd>let @/ = ""<cr>', 'Clean the search pattern')
map('n', '<leader>ev', '<cmd>e $MYVIMRC<cr>', 'Edit the RC config file')

------- Terminal

-- keybindings.
-- Exit terminal mode.
vim.cmd([[:tnoremap <A-q> <C-\><C-n>]])
-- Use ALT + j/k to switch buffers from terminal mode.
vim.cmd([[
:tnoremap <A-j> <C-\><C-N> :bprev<cr>
:tnoremap <A-k> <C-\><C-N> :bnext<cr>
]])
-- Real clear.
vim.cmd([[
nmap <c-w><c-l> :set scrollback=1 \| sleep 100m \| set scrollback=10000<cr>
tmap <c-w><c-l> <c-\><c-n><c-w><c-l>i<c-l>
]])

-- Adjust configuration for terminal buffers.
vim.cmd [[autocmd TermOpen * setlocal listchars= nonumber norelativenumber signcolumn=no]]

return {
  -- This function gets run when an LSP connects to a particular buffer.
  on_attach = function(_, bufnr)
    local function buf_map(keys, func, desc)
      map('n', keys, func, desc, { buffer = bufnr })
    end

    buf_map('<leader>rn', vim.lsp.buf.rename, '[r]e[n]ame')
    buf_map('<leader>ca', vim.lsp.buf.code_action, '[c]ode [a]ction')
    buf_map('<leader>f', vim.lsp.buf.format, '[f]ormat')

    buf_map('gd', vim.lsp.buf.definition, '[g]oto [d]efinition')
    buf_map('gi', vim.lsp.buf.implementation, '[g]oto [i]mplementation')
    buf_map('gt', vim.lsp.buf.type_definition, '[g]oto [t]ype definition')

    -- LSP support from plugins (the default quickfix window is less appealing).
    buf_map('gr', function() require('trouble').open("lsp_references") end, '[g]oto [r]eferences')
    -- buf_map('gr', require('telescope.builtin').lsp_references, '[g]oto [r]eferences')
    -- buf_map('gr', vim.lsp.buf.references, '[g]oto [r]eferences')
    --
    buf_map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[d]ocument [s]ymbols')
    -- buf_map('<leader>ds', vim.lsp.buf.document_symbol, '[d]ocument [s]ymbols')
    --
    buf_map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[w]orkspace [s]ymbols')
    -- buf_map('<leader>ws', vim.lsp.buf.workspace_symbol, '[w]orkspace [s]ymbols')

    -- See `:help K` for why this keymap
    buf_map('K', vim.lsp.buf.hover, 'Hover Documentation')
    buf_map('<leader>sh', vim.lsp.buf.signature_help, '[s]ignature [h]elp')

    -- Lesser used LSP functionality
    buf_map('gD', vim.lsp.buf.declaration, '[g]oto [D]eclaration')
    buf_map('<leader>wa', vim.lsp.buf.add_workspace_folder, '[w]orkspace [a]dd folder')
    buf_map('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[w]orkspace [r]emove folder')
    buf_map('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, '[w]orkspace [l]ist folders')

    -- From scala metals.
    buf_map('<leader>cl', vim.lsp.codelens.run, '[c]ode [l]ens')

    -- Create a command `:Format` local to the LSP buffer
    -- NOTE: can be mapped to something simpler, like maybe <leader>f
    vim.api.nvim_buf_create_user_command(
      bufnr,
      'Format',
      function(_)
        vim.lsp.buf.format()
      end,
      { desc = 'Format current buffer with LSP' })
  end
}

-- vim: ts=2 sts=2 sw=2 et
