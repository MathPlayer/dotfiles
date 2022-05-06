" Use the terminal cursor.
set guicursor=
" Workaround for some broken plugins which set guicursor indiscriminately.
autocmd OptionSet guicursor noautocmd set guicursor=

" Use the system clipboard.
set clipboard+=unnamedplus

" Use the vim configuration.
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Use a custom Python environment installed with pyenv.
let g:neovim_python_env="~/.pyenv/versions/neovim"
let g:python3_host_prog=g:neovim_python_env."/bin/python3"

" Use a custom Node environment installed with nodenv.
"let g:node_host_prog="~/.nodenv/versions/16.4.2/bin/node"

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
if &runtimepath =~ 'nvim-lspconfig'
  " Load lsp and completion.
  lua << BLOCK
  lsp_config = require'lspconfig'
  completion_callback = require'completion'.on_attach

  lsp_config.pylsp.setup {
    cmd_env = {
      VIRTUAL_ENV=vim.g.neovim_python_env,
      PATH=vim.g.neovim_python_env .. "/bin/" .. ":" .. vim.env.PATH
      },
    on_attach = completion_callback
  }

  lsp_config.bashls.setup{}
  lsp_config.tsserver.setup{}
  lsp_config.clangd.setup {}
  lsp_config.yamlls.setup {
    settings = {
      yaml = {
        schemas = {
          ["azure-pipelines/yamlschema.json"] = "/azure-pipelines/**/*"
        }
      }
    }
  }
BLOCK

  " Disgnostics signs
  sign define LspDiagnosticsSignError text=🔴
  sign define LspDiagnosticsSignWarning text=🟠
  sign define LspDiagnosticsSignInformation text=🔵
  sign define LspDiagnosticsSignHint text=🟢

  " Keybindings
  nnoremap <silent> <leader>gd  <cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap <silent> <leader>gD  <cmd>lua vim.lsp.buf.declaration()<CR>
  nnoremap <silent> <leader>gi  <cmd>lua vim.lsp.buf.implementation()<CR>
  nnoremap <silent> <leader>gr  <cmd>lua vim.lsp.buf.references()<CR>
  "nnoremap <silent> <leader>ge  <cmd>lua vim.lsp.diagnostic.set_loclist()<CR>
  nnoremap <silent> <leader>K   <cmd>lua vim.lsp.buf.hover()<CR>
  nnoremap <silent> <leader>bf   <cmd>lua vim.lsp.buf.formatting()<CR>
  nnoremap <silent> <leader>rn  <cmd>lua vim.lsp.buf.rename()<CR>
  "nnoremap <silent> <leader>a <cmd>lua vim.lsp.buf.code_action()<CR>
  "xmap <silent> <leader>a <cmd>lua vim.lsp.buf.range_code_action()<CR>

  " Navigate through popup menu
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  " Set completeopt to have a better completion experience
  set completeopt=menuone,noinsert,noselect
  " Avoid showing message extra message when using completion
  set shortmess+=c


  " disable the automatic show for the completion popup
  let g:completion_enable_auto_popup = 0
  " Smart triggers for using Tab in order to trigger the autocomplete.
  imap <tab> <Plug>(completion_smart_tab)
  imap <s-tab> <Plug>(completion_smart_s_tab)
endif

