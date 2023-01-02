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

  lsp_config.pylsp.setup {
    cmd_env = {
      VIRTUAL_ENV=vim.g.neovim_python_env,
      PATH=vim.g.neovim_python_env .. "/bin/" .. ":" .. vim.env.PATH
      },
  }

  lsp_config.bashls.setup{}
  lsp_config.tsserver.setup{}
  lsp_config.clangd.setup {}
  lsp_config.yamlls.setup {
    settings = {
      yaml = {
        trace = {
          server = "verbose"
        },
        schemas = {
          ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/main/service-schema.json"] = "/azure-pipelines/**/*",
          ["/Users/popescub/work/.config/nvim/tomtom-ado-yamlschema.json"] = "/azure-pipelines/**/*",
          ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
          ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = "/navcloud-cluster.yml",
          ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = "/**/cf-templates/*.yml"
        },
        customTags = {
          "!And scalar",
          "!And mapping",
          "!And sequence",
          "!If scalar",
          "!If mapping",
          "!If sequence",
          "!Not scalar",
          "!Not mapping",
          "!Not sequence",
          "!Equals scalar",
          "!Equals mapping",
          "!Equals sequence",
          "!Or scalar",
          "!Or mapping",
          "!Or sequence",
          "!FindInMap scalar",
          "!FindInMap mappping",
          "!FindInMap sequence",
          "!Base64 scalar",
          "!Base64 mapping",
          "!Base64 sequence",
          "!Cidr scalar",
          "!Cidr mapping",
          "!Cidr sequence",
          "!Ref scalar",
          "!Ref mapping",
          "!Ref sequence",
          "!Sub scalar",
          "!Sub mapping",
          "!Sub sequence",
          "!GetAtt scalar",
          "!GetAtt mapping",
          "!GetAtt sequence",
          "!GetAZs scalar",
          "!GetAZs mapping",
          "!GetAZs sequence",
          "!ImportValue scalar",
          "!ImportValue mapping",
          "!ImportValue sequence",
          "!Select scalar",
          "!Select mapping",
          "!Select sequence",
          "!Split scalar",
          "!Split mapping",
          "!Split sequence",
          "!Join scalar",
          "!Join mapping",
          "!Join sequence"
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

if &runtimepath =~ 'nvim-tree'
  lua << BLOCK
  require'nvim-tree'.setup()
BLOCK

  " mappings
  nnoremap <leader>nn :NvimTreeToggle<CR>
  nnoremap <leader>nf :NvimTreeFindFile<CR>

endif

" if &runtimepath =~ 'vscode.nvim'
"
"   lua << BLOCK
"   vim.o.background = 'dark'
"   local c = require('vscode.colors')
"   require('vscode').setup({
"     -- Disable nvim-tree background color
"     disable_nvimtree_bg = true,
"
"     -- Override colors (see ./lua/vscode/colors.lua)
"     color_overrides = {
"       vscLineNumber = '#FFFFFF',
"     },
"
"     -- Override highlight groups (see ./lua/vscode/theme.lua)
"     group_overrides = {
"       -- this supports the same val table as vim.api.nvim_set_hl
"       -- use colors from this colorscheme by requiring vscode.colors!
"       Cursor = { fg=c.vscDarkBlue, bg=c.vscLightGreen, bold=true },
"     }
"   })
" BLOCK
"
" endif
