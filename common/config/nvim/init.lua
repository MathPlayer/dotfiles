---- Helpers for this file
local HOME = os.getenv('HOME')

---- General
-- Disable the GUI cursor / use the terminal one.
vim.opt.guicursor = ''
-- Workaround for some broken plugins which set guicursor indiscriminately.
vim.cmd('autocmd OptionSet guicursor noautocmd set guicursor=')
-- Use the system clipboard.
vim.cmd('set clipboard+=unnamedplus')

---- Tool config
-- Use a custom Python environment installed with pyenv.
vim.g.neovim_python_env=HOME .. "/.config/nvim/.venv"
vim.g.python3_host_prog=vim.g.neovim_python_env .. "/bin/python3"

---- appearance
-- use 24-bit colors
vim.opt.termguicolors = true
--  Improve visual performance by not redrawing the screen when executing some commands
vim.opt.lazyredraw = true
-- show line numbers...
vim.opt.number = true

-- TODO: convert to lua equivalent
vim.cmd([[
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ... except when on quickfix
autocmd FileType qf setlocal nonumber
" show the 'line,columns' on the bar
set ruler
" highlight the cursor line
" XXX: using this + vertical splits is sometimes slow in vim
set cursorline
" show matching brackets
set showmatch
" set text maximum width to 99 (100 including newline) - except when on quickfix
set textwidth=119
if exists('+colorcolumn')
  set colorcolumn=120
  autocmd FileType qf setlocal colorcolumn=
else
  autocmd BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>119v.\+', -1)
  " TODO remove matchadd on quickfix window for older versions of vim
endif
" Always show the signcolumn, except for plugins configured below
autocmd BufRead,BufNewFile * setlocal signcolumn=yes


"----- indent ------"
" copy indent from current line when starting a new line
set autoindent
" smart indent when starting a new line
set smartindent
" c-like indent, more strict than smartindent; do not use them simultanously
"set cindent


"----- tabs -----"
" spaces a tab counts for
set tabstop=2
" spaces inserted when hitting tab in Insert mode
set expandtab
" spaces inserted with reindent operations
set shiftwidth=2
" spaces vim uses when hitting Tab in insert mode
"   - if not equal to tabstop, vim will use a combination of tabs and spaces to
"       make up the desired spacing
"   - if equal to tabstop, vimm will insert spaces/tabs for it, depending
"       whether expandtab in on or off
set softtabstop=2


"----- whitespace -----"
" display whitespace characters
set list
" characters to show for tab, trailing whitespace and normal space
try
  set listchars=tab:→\ ,trail:~,nbsp:·
catch
  set listchars=tab:>\ ,trail:_,nbsp:~
endtry
set showbreak=\\   " the spaces are needed


"----- search -----"
" highlight the search phrase
set hlsearch
" highlight while typing the search phrase
set incsearch
" do case insensitive matching
set ignorecase
" override ignorecase if pattern contains upper case characters
set smartcase


"----- highlight colors -----"
" change search highlight color
highlight Search cterm=NONE ctermfg=black ctermbg=darkblue gui=NONE guifg=black guibg=darkblue
" change TODO highlight color
highlight TODO cterm=NONE ctermfg=red ctermbg=black gui=NONE guifg=red guibg=black
" change bracket match highlight color
highlight MatchParen ctermfg=red ctermbg=black guifg=red guibg=black
" Reset bad spelling highlight, use only underline
highlight clear SpellBad
highlight SpellBad cterm=underline
" Improve SignColumn color
highlight SignColumn ctermbg=darkgrey guibg=darkgrey
highlight SpecialKey cterm=NONE ctermfg=grey gui=NONE guifg=grey
" tabline fill space
"highlight TabLineFill ctermbg=black guibg=black
" highlight trailing whitespace as errors
highlight default link ExtraWhitespace Error
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
augroup HighlightWhitespace
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
augroup END

"----- menu and status -----"
" always show the status line
set laststatus=2
" turn on command line completion wild style
set wildmenu
" turn on wild mode huge list
set wildmode=list:longest
" show partial commands in last line of screen
set showcmd


"----- miscellaneous -----"
" use smart backspaces over enumerated elements
set backspace=eol,start,indent
" don't wrap lines
set nowrap
" do not save backup files
set nobackup
" do not save swap files
set noswapfile
" remember 1000 commands and history
set history=1000
" set levels of undo
set undolevels=2000
" splitting a window will put the new one below the current one
set splitbelow
" splitting a window will put the new one right to the current one
set splitright
" use mouse with the new sgr protocol (i.e. useful to scroll on big terminals)
if has('mouse_sgr')
  set ttymouse=sgr
endif
" use mouse (=a -> anywhere possible)
set mouse=a
" set timeout between consecutive characters type when entering a command
" sequence
set timeoutlen=500


"----- key mappings -----"
" Edit and reload vimrc
map <leader>ev :e $MYVIMRC<cr>
map <leader>sv :so $MYVIMRC<cr>
" Clear search results by pressing Enter
nnoremap <leader><CR> :noh<CR><CR>
" easy search highlighted text (visual highlight and press //)
vnoremap <expr> // 'y/\V'.escape(@",'\').'<CR>'
" Have <esc> leave cmdline-window (I do not use it)
autocmd CmdwinEnter * nnoremap <buffer> <esc> :q\|echo ""<cr>
"fast buffer switch
nnoremap <A-j> :bprev<CR>
nnoremap <A-k> :bnext<CR>
" switch buffers without save
set hidden
" Change work directory to parent of current file.
nnoremap <leader>cd :cd %:p:h<CR>:pwd<CR>

" set key for paste toogle (when active, the pasted text formatting is not
" modified by any indent feature)
set pastetoggle=<F2>

" Format json files.
map <leader>jf :%!python -m json.tool<cr>

"----- misc -----"

fun! StripTrailingWhitespace()
  " function to remove trailing whitespaces
  let L = line(".")
  let C = col(".")
  %s/\s\+$//e
  call cursor(L, C)
endfun
"---- call above function on each write;
" Internet says it's unsafe if you edit binary files
" XXX: call it on exit for file, not on each write
" FIXME: strip trailing whitespace only on edited lines
" autocmd BufWrite  * :call <SID>StripTrailingWhitespaces()
command StripTrailingWhitespace call StripTrailingWhitespace()

" Set specific syntax
" objective-c vs octave problem
augroup filetypedetect
  " au! BufRead, BufNewFile *.m,*.oct set filetype=octave
  au! BufRead,BufNewFile,BufRead *.m set filetype=objc
  au! BufRead,BufNewFile,BufRead *.mm set filetype=objcpp
augroup END
augroup filetypedetect
  au! BufRead, BufNewFile *.xcconfig set filetype=xcconfig
augroup END
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  ]])

------- Key mappings
vim.keymap.set('n', ' ', '<Nop>', {desc = 'Ignore SPACE in normal mode since it gets set to LEADER.'})
vim.g.mapleader = " "

vim.keymap.set('n', ';', ':', {desc = 'More efficient command calling via :'})
vim.keymap.set('c', 'w!!', ' w !sudo tee % >/dev/null', {desc = 'Write a file with sudo'})
vim.keymap.set('n', '-', '@="ddp"<cr>', {desc = 'Move a line up; can be used with numbers'})
vim.keymap.set('n', '_', '@="ddkP"<cr>', {desc = 'Move a line down; can be used with numbers'})
vim.keymap.set('n', '<leader>"', 'viw<esc>a"<esc>hbi"<esc>lel', {desc = 'Surround a word by double quotes'})
vim.keymap.set('n', "<leader>'", "viw<esc>a'<esc>hbi'<esc>lel", {desc = 'Surround a word by single quotes'})
vim.keymap.set('n', 'H', '^', {desc = 'Go to beggining of the current line'})
vim.keymap.set('n', 'L', '$', {desc = 'Go to the end of the current line'})

vim.keymap.set('n', '*', '*zz', {desc = 'Search and center screen'})

-- Taken from https://stackoverflow.com/a/657457/1549098
vim.keymap.set('n', '<leader><cr>', '<cmd>let @/ = ""<cr>', {desc = 'Clean the search pattern'})
vim.keymap.set('n', '<leader>ev', '<cmd>e $MYVIMRC<cr>', {desc = 'Edit the RC config file'})
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
vim.cmd('autocmd TermOpen * setlocal listchars= nonumber norelativenumber signcolumn=no')

---- plugin settings
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Color themes
  -- NOTE: colorschemes are loaded early, as instructed in first example at
  -- https://github.com/folke/lazy.nvim/blob/main/README.md?plain=1#L201
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- load the colorscheme here
      -- vim.o.background = 'dark'
      -- vim.cmd('colorscheme tokyonight')
    end,
  },
  {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- load the colorscheme here
       -- vim.o.background = 'dark'
       -- vim.cmd('colorscheme gruvbox')
       -- vim.g.gitgutter_override_sign_column_highlight=1
    end,
  },
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      -- load the colorscheme here
      vim.o.background = 'dark'
      vim.cmd('colorscheme onedark')
    end,
  },

  -- treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      local treesitter_configs = require('nvim-treesitter.configs')
      vim.opt.runtimepath:append("$HOME/.local/share/treesitter") -- Avoid installing the parsers on each start
      treesitter_configs.setup {
        -- A list of parser names, or "all" (the five listed parsers should always be installed)
        ensure_installed = 'all',

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        highlight = {
          enable = true,
          -- Disable slow treesitter highlight for large files
          disable = function(lang, buf)
              local max_filesize = 100 * 1024 -- 100 KB
              local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
              if ok and stats and stats.size > max_filesize then
                  return true
              end
          end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
      }
      -- vim.opt.foldmethod = 'expr'
      -- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
      -- Disable folding at startup
      -- vim.opt.foldenable = false
    end
  },

  -- Fuzy finder + deps
  -- Deps instructions taken/adjusted from: https://github.com/nvim-telescope/telescope-fzf-native.nvim#packernvim
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim'
    },
    version = '*',
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>' },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup()
      telescope.load_extension('fzf')
    end,
  },

  -- Code outline
  {
    'stevearc/aerial.nvim',
    opts = {
      -- optionally use on_attach to set keymaps when aerial has attached to a buffer
      on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set('n', '{', '<cmd>AerialPrev<cr>', {buffer = bufnr})
        vim.keymap.set('n', '}', '<cmd>AerialNext<cr>', {buffer = bufnr})
      end,
      -- Don't show it for certain elements
      ignore = {
        buftypes = {
          'special',
          'nofile',
          'terminal',
        },
        filetypes = {
          'help',
          'lazy',
          'nvimtree',
        },
      },
    },
    keys = {
      { '<leader>aa', '<cmd>AerialToggle!<cr>' },
    },
  },
  {
    'SmiteshP/nvim-navic',
    dependencies = {
      'neovim/nvim-lspconfig'
    },
    opts = {
      lsp = {
        auto_attach = true,
      },
    },
  },

  -- File browser
  {
    'nvim-tree/nvim-tree.lua',
    config = true,
    keys = {
      { '<leader>nn', '<cmd>NvimTreeToggle<cr>' },
      { '<leader>nf', '<cmd>NvimTreeFindFile<cr>' },
    },
    opts = {
      view = {
        preserve_window_proportions = true,
        signcolumn = 'no',
      },
      renderer = {
        highlight_git = true,
      },
    },
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Tint the current / active window
  -- { 'levouh/tint.nvim', config = true },

  -- Better statusline / tabline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'stevearc/aerial.nvim',
      'SmiteshP/nvim-navic',
    },
    opts = {
      options = {
        -- theme = 'tokyonight',
        -- theme = 'gruvbox',
        theme = 'onedark',
      },
      tabline = {
        lualine_a = { 'buffers' },
      },
    },
  },

  -- better (a.k.a. ultra) folds
  -- See https://github.com/kevinhwang91/nvim-ufo/issues/4#issuecomment-1411582218
  -- for the nvim-ufo + statuscom.nvim combo
  {
    'luukvbaal/statuscol.nvim',
    config = function()
      local builtin = require('statuscol.builtin')
      require('statuscol').setup(
      {
        relculright = true,
        segments = {
          {text = {builtin.lnumfunc, ' '}, click = 'v:lua.ScLa'},
          {text = {builtin.foldfunc}, click = 'v:lua.ScFa'},
          {text = {'%s'}, click = 'v:lua.ScSa'},
        }
      })
      end
  },
  {
    'kevinhwang91/nvim-ufo',
    dependencies = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter',
      'luukvbaal/statuscol.nvim',
    },
    config = function()
      -- opts = {
      --   provider_selector = function(bufnr, filetype, buftype)
      --     return {'treesitter', 'indent'}
      --   end,
      -- },
      -- Taken from https://github.com/kevinhwang91/nvim-ufo#minimal-configuration

      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.fillchars = [[eob: ,fold: ,foldopen:▼,foldsep: ,foldclose:▶]]

      -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
      vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
      vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)
      require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
          return {'treesitter', 'indent'}
        end
      })
    end
  },

  --  Add indent guide lines
  {
    'lukas-reineke/indent-blankline.nvim',
    opts = {
      show_current_context = true,
      show_current_context_start = true,
    },
  },

  -- Do not alter window structure when closing buffers
  'moll/vim-bbye',

  -- highlight the word under cursor
  'itchyny/vim-cursorword',

  -- Toggle using mouse in vim or not
  'nvie/vim-togglemouse',

  -- easy commenting
  {
    'preservim/nerdcommenter',
    init = function()
      vim.g.NERDSpaceDelims = 1
      vim.g.NERDCommentEmptyLines = 1
      vim.g.NERDDefaultAlign = 'left'
    end
  },

  -- file-line easy opening
  'lervag/file-line',

  -- compare directories in vim
  'will133/vim-dirdiff',

  -- enhanced filetype syntax
  { 'pboettch/vim-cmake-syntax', ft = 'cmake' }, -- TODO: consider removing as it doesn't seem to work in neovim
  { 'keith/xcconfig.vim', ft = 'xcconfig' },
  { 'cfdrake/vim-pbxproj',ft = 'pbxproj' },
  { 'vim-scripts/SWIG-syntax', ft = 'swig' },
  { 'towolf/vim-helm', lazy = false }, -- Helm templates


  -- Javascript plugins
  { 'jelera/vim-javascript-syntax', ft = 'javascript' },
  { 'ternjs/tern_for_vim', ft = 'javascript' },
  { 'pangloss/vim-javascript', ft = 'javascript' },
  { 'maksimr/vim-jsbeautify', ft = 'javascript' },

  -- HTML plugins
  { 'othree/html5.vim', ft = 'html' },

  -- YAML plugins
  --{
  --  'cuducos/yaml.nvim',
  --  ft = 'yaml',
  --  dependencies = {
  --    'nvim-treesitter/nvim-treesitter',
  --    'nvim-telescope/telescope.nvim' -- optional
  --  },
  --},

  -- Git plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  {
    'junegunn/gv.vim',
    dependencies = {
      'tpope/vim-fugitive',
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      -- Copied from https://github.com/lewis6991/gitsigns.nvim#keymaps
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        -- Actions
        map({'n', 'v'}, '<leader>ha', gs.stage_hunk)
        map({'n', 'v'}, '<leader>hr', gs.reset_hunk)
        map({'n', 'v'}, '<leader>hrs', gs.undo_stage_hunk)
        map('n', '<leader>hS', gs.stage_buffer)
        map('n', '<leader>hR', gs.reset_buffer)
        map('n', '<leader>hp', gs.preview_hunk)
        map('n', '<leader>hb', function() gs.blame_line{full=true} end)
        map('n', '<leader>tb', gs.toggle_current_line_blame)
        map('n', '<leader>hd', gs.diffthis)
        map('n', '<leader>hD', function() gs.diffthis('~') end)
        map('n', '<leader>td', gs.toggle_deleted)

        -- Text object
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end
    }
  },
  -- Markdown
  -- The tabular plugin is recommended in the vim-markdown README:
  -- https://github.com/preservim/vim-markdown/blob/master/README.md?plain=1#L21
  {
    'preservim/vim-markdown',
    ft = 'markdown',
    dependencies = { 'godlygeek/tabular' },
    init = function()
      vim.g.markdown_folding = 1
      vim.g.vim_markdown_folding_disabled = 1
    end
  },
  { 'mzlogin/vim-markdown-toc', ft = 'markdown' },
  -- If you don't have nodejs and yarn
  -- use pre build, add 'vim-plug' to the filetype list so vim-plug can update this plugin
  -- see: https://github.com/iamcco/markdown-preview.nvim/issues/50
  { 'iamcco/markdown-preview.nvim', build = ':call mkdp#util#install()', ft = 'markdown' },

  -- my own
  { dir = '~/.vim/my-configs' },

  -- Language grammar checker via languagetool
  {
    'dpelle/vim-LanguageTool',
    init = function()
      vim.g.languagetool_cmd = '/usr/local/bin/languagetool'  -- installed with brew on macos
    end,
  },

  -- extra config for lsp
  'neovim/nvim-lspconfig',

  {
    'scalameta/nvim-metals',
    dependencies = {
      'nvim-lua/plenary.nvim'
    },
  },
})

local ok, navic = pcall(require, 'nvim-navic')
if ok then
  vim.o.winbar="%{%v:lua.require'nvim-navic'.get_location()%}"
end

-- lspconfig
local ok, lsp_config = pcall(require, 'lspconfig')
if ok then
  -- Load lsp and completion.
  lsp_config.pylsp.setup {
    cmd_env = {
      VIRTUAL_ENV=vim.g.neovim_python_env,
      PATH=vim.g.neovim_python_env .. "/bin/" .. ":" .. vim.env.PATH
      },
  }

  lsp_config.bashls.setup {}
  lsp_config.tsserver.setup {}
  lsp_config.clangd.setup {}
  lsp_config.marksman.setup {}
  lsp_config.helm_ls.setup {
    filetypes = {"helm"},
    cmd = {"helm_ls", "serve"},
  }
  -- lsp_config.yamlls.setup {
  --   filetypes = { "yaml", "yaml.docker-compose" },
  --   settings = {
  --     yaml = {
  --       --trace = {
  --         --server = "verbose"
  --       --},
  --       schemas = {
  --         ["https://raw.githubusercontent.com/microsoft/azure-pipelines-vscode/main/service-schema.json"] = "/azure-pipelines/**/*",
  --         ["/Users/popescub/work/.config/nvim/tomtom-ado-yamlschema.json"] = "/azure-pipelines/**/*",
  --         ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
  --         ["https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json"] = "/**/cf-templates/*.yml",
  --       },
  --       customTags = {
  --         "!And scalar",
  --         "!And mapping",
  --         "!And sequence",
  --         "!If scalar",
  --         "!If mapping",
  --         "!If sequence",
  --         "!Not scalar",
  --         "!Not mapping",
  --         "!Not sequence",
  --         "!Equals scalar",
  --         "!Equals mapping",
  --         "!Equals sequence",
  --         "!Or scalar",
  --         "!Or mapping",
  --         "!Or sequence",
  --         "!FindInMap scalar",
  --         "!FindInMap mappping",
  --         "!FindInMap sequence",
  --         "!Base64 scalar",
  --         "!Base64 mapping",
  --         "!Base64 sequence",
  --         "!Cidr scalar",
  --         "!Cidr mapping",
  --         "!Cidr sequence",
  --         "!Ref scalar",
  --         "!Ref mapping",
  --         "!Ref sequence",
  --         "!Sub scalar",
  --         "!Sub mapping",
  --         "!Sub sequence",
  --         "!GetAtt scalar",
  --         "!GetAtt mapping",
  --         "!GetAtt sequence",
  --         "!GetAZs scalar",
  --         "!GetAZs mapping",
  --         "!GetAZs sequence",
  --         "!ImportValue scalar",
  --         "!ImportValue mapping",
  --         "!ImportValue sequence",
  --         "!Select scalar",
  --         "!Select mapping",
  --         "!Select sequence",
  --         "!Split scalar",
  --         "!Split mapping",
  --         "!Split sequence",
  --         "!Join scalar",
  --         "!Join mapping",
  --         "!Join sequence"
  --       }
  --     }
  --   }
  -- }

  -- Signs not added when moving from init.vim to init.lua
  -- sign define LspDiagnosticsSignError text=🔴
  -- sign define LspDiagnosticsSignWarning text=🟠
  -- sign define LspDiagnosticsSignInformation text=🔵
  -- sign define LspDiagnosticsSignHint text=🟢

  -- C/P from https://github.com/neovim/nvim-lspconfig#suggested-configuration

  -- Global mappings.
  -- See `:help vim.diagnostic.*` for documentation on any of the below functions
  vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
  vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

  -- Use LspAttach autocommand to only map the following keys
  -- after the language server attaches to the current buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
      -- set up navic for the current buffer
      local client = vim.lsp.get_client_by_id(args.data.client_id)

      -- Enable completion triggered by <c-x><c-o>
      if client.server_capabilities.completionProvider then
        vim.bo[args.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
      end

      -- Buffer local mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      local opts = { buffer = args.buf }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
      vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, opts)
      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
      vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
      vim.keymap.set('n', '<space>f', function()
        vim.lsp.buf.format { async = true }
      end, opts)
    end,
  })
end

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

-- Uncomment when debugging LSP servers.
-- vim.lsp.set_log_level("debug")
