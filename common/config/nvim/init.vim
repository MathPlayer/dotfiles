" Use the terminal cursor.
set guicursor=
let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 0
" Workaround for some broken plugins which set guicursor indiscriminately.
autocmd OptionSet guicursor noautocmd set guicursor=

" Use the system clipboard.
set clipboard+=unnamedplus

" Use the vim configuration.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc


"----- Terminal -----"

" keybindings.
" Exit terminal mode.
:tnoremap <A-q> <C-\><C-n>
" Use ALT + j/k to switch buffers from terminal mode.
:tnoremap <A-j> <C-\><C-N> :bprev<cr>
:tnoremap <A-k> <C-\><C-N> :bnext<cr>
" Real clear.
nmap <c-w><c-l> :set scrollback=1 \| sleep 100m \| set scrollback=10000<cr>
tmap <c-w><c-l> <c-\><c-n><c-w><c-l>i<c-l>

" Adjust configuration for terminal buffers.
autocmd TermOpen * setlocal listchars= nonumber norelativenumber signcolumn=no


"----- plugin settings -----"
if &runtimepath =~ 'nvim-lsp'
  " LSP servers.
  " TODO: fill setup configuration for better autocomplete (like no return type filled out, etc).
  lua require'nvim_lsp'.ccls.setup{}
  lua require'nvim_lsp'.pyls.setup{}
  " Keybindings.
  nnoremap <silent> <leader>ad <cmd>lua vim.lsp.buf.declaration()<CR>
  nnoremap <silent> <leader>aD <cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap <silent> <leader>ah <cmd>lua vim.lsp.buf.hover()<CR>
  nnoremap <silent> <leader>ai <cmd>lua vim.lsp.buf.implementation()<CR>
  nnoremap <silent> <leader>as <cmd>lua vim.lsp.buf.signature_help()<CR>
  nnoremap <silent> <leader>at <cmd>lua vim.lsp.buf.type_definition()<CR>
  nnoremap <silent> <leader>ar <cmd>lua vim.lsp.buf.references()<CR>

  " set omnifunc>
  autocmd Filetype c,cpp,python setlocal omnifunc=v:lua.vim.lsp.omnifunc
endif
