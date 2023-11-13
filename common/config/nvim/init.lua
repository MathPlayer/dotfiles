---- Helpers for this file
local HOME = os.getenv('HOME')
local api = vim.api
local map = require('utils').map

--  This function gets run when an LSP connects to a particular buffer.
local lsp_on_attach = function(_, bufnr)
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
  api.nvim_buf_create_user_command(
    bufnr,
    'Format',
    function(_)
      vim.lsp.buf.format()
    end,
    { desc = 'Format current buffer with LSP' })
end

-- Remap the LEADER key before loading any plugins.
map({'n', 'v'}, '<Space>', '<Nop>', 'Disable Space since it gets mapped as Leader.', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

---- plugin settings
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  { import = 'plugins' },

  -- treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    -- NOTE: consider adding the dependencies listed by kickstart.nvim:
    -- https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua#L189
  },

  -- Fuzy finder + deps
  -- Deps instructions taken/adjusted from: https://github.com/nvim-telescope/telescope-fzf-native.nvim#packernvim
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    -- Check https://github.com/nvim-lua/kickstart.nvim/blob/master/init.lua#L179 in case this fails.
  },
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-fzf-native.nvim',
      'folke/trouble.nvim',
    },
    version = '*',
    config = function()
      local telescope = require('telescope')
      local ta = require('telescope.actions')
      local trouble = require("trouble.providers.telescope")
      telescope.setup {
        -- https://github.com/nvim-telescope/telescope-fzf-native.nvim#telescope-setup-and-configuration
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                             -- the default case_mode is "smart_case"
          },
        },
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<c-t>'] = trouble.open_with_trouble,
              ['<c-h>'] = ta.which_key,
              ['<c-d>'] = ta.delete_buffer + ta.move_to_top,  -- Delete buffers. what happens if CTRL-d is pressed in another picker?!
            },
            n = {
              ['<c-t>'] = trouble.open_with_trouble,
            },
          },
          layout_strategy = 'vertical',
          layout_config = {
            mirror = true,
            prompt_position = 'top',
            -- height = 0.95,
            -- width = 0.95,
          },
        },
      }
      telescope.load_extension('fzf')
    end,
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>nt', '<cmd>Neotree toggle<cr>', desc = '[Neotree] Toggle' },
      { '<leader>nf', '<cmd>Neotree reveal<cr>', desc = '[Neotree] File reveal' },
    },
    config = function ()
      require('neo-tree').setup {
        filesystem = {
          group_empty_dirs = true,
        },
      }
    end
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Tint the current / active window
  { 'levouh/tint.nvim', config = true },

  { 'Bekaboo/dropbar.nvim' },

  -- Better statusline / tabline
  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      'stevearc/aerial.nvim',
    },
    opts = {
      options = {
        -- theme = 'tokyonight',
        -- theme = 'gruvbox',
        theme = 'onedark',
        icons_enabled = false,
        component_separators = '|',
        section_separators = ''
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
      -- Taken from https://github.com/keinhwang91/nvim-ufo#minimal-configuration

      vim.o.foldcolumn = '1' -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.fillchars = [[eob: ,fold: ,foldopen:▼,foldsep: ,foldclose:▶]]

      -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself

      map('n', 'zR', require('ufo').openAllFolds, '[ufo] open all folds (recursively)')
      map('n', 'zM', require('ufo').closeAllFolds, '[ufo] close all folds')
      require('ufo').setup({ provider_selector = function() return {'treesitter', 'indent'} end })
    end
  },

  --  Add indent guide lines
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '┊',
      },
    },
  },

  -- Do not alter window structure when closing buffers
  'moll/vim-bbye',

  -- Better trailing whitespace functionality
  { 'echasnovski/mini.trailspace', version = false },

  -- highlight the word under cursor
  'itchyny/vim-cursorword',

  -- Show you pending keybinds
  { 'folke/which-key.nvim', opts = {} },

  -- Toggle using mouse in vim or not
  'nvie/vim-togglemouse',

  -- easy commenting
  -- {
  --   'preservim/nerdcommenter',
  --   init = function()
  --     vim.g.NERDSpaceDelims = 1
  --     vim.g.NERDCommentEmptyLines = 1
  --     vim.g.NERDDefaultAlign = 'left'
  --   end
  -- },
  { 'numToStr/Comment.nvim', opts = {} },

  -- file-line easy opening
  'lervag/file-line',

  -- detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

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
  { -- XXX: config taken from kickstart.nvim
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      -- 'folke/neodev.nvim',
    },
  },

  -- Autocompletion
  { -- XXX: taken from kickstart.nvim
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
  },

  {
    'scalameta/nvim-metals',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- 'mfussenegger/nvim-dap',
    },
    ft = { 'scala', 'sbt', 'java' },
    keys = {
      { '<leader>mc', function() require('telescope').extensions.metals.commands() end, desc = '[m]etals [c]ommands' },
      { '<leader>mcc', function() require('metals').compile_cascade() end,               desc = '[m]etals [c]ompile [c]ascade' },
    },
    init = function()
      vim.opt_global.completeopt = { 'menuone', 'noinsert', 'noselect' }
      map('n', '<leader>ws', function() require('metals').hover_worksheet() end)
      map('n', '<leader>mds', vim.lsp.buf.document_symbol)
      map('n', '<leader>mws', vim.lsp.buf.workspace_symbol)
      map('n', '<leader>mi', function() require('metals').toggle_setting('showImplicitArguments') end)
      local metals = require('metals')
      local metals_config = metals.bare_config()
      metals_config.settings = {
        showImplicitArguments = true,
        excludedPackages = {
          'akka.actor.typed.javadsl',
          'com.github.swagger.akka.javadsl'
        },
        serverVersion = 'latest.snapshot',
      }
      metals_config.on_attach = lsp_on_attach
      local nvim_metals_group = api.nvim_create_augroup('nvim-metals', { clear = true })
      api.nvim_create_autocmd('FileType', {
        pattern = { 'scala', 'sbt', 'java' },
        callback = function()
          metals.initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end
  },
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate' -- :MasonUpdate updates registry contents
  },

  -- Code outline
  {
    'stevearc/aerial.nvim',
    opts = {
      on_attach = function(bufnr)
        map('n', '{', '<cmd>AerialPrev<cr>', '[Aerial] jump to next tag', { buffer = bufnr })
        map('n', '}', '<cmd>AerialNext<cr>', '[Aerial] jump to previous tag', { buffer = bufnr })
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
      { '<leader>ss', '<cmd>AerialToggle!<cr>' },
    },
  },
  {
    "folke/trouble.nvim",
    keys = {
      { "<leader>d", "<cmd>TroubleToggle<cr>", desc = "[Trouble] toggle" },
      { "<leader>D", "<cmd>Trouble<cr>", desc = "[Trouble] open" },
      { '<leader>dl', function() require('trouble').open('loclist') end, desc = '[Trouble] Open [l]ocal (buffer) diagnostics list' },
      { '<leader>dq', function() require('trouble').open('quickfix') end, desc = '[Trouble] Open [q]uickfix diagnostics list' },
      {
        "<leader><leader>",
        function()
          local trouble = require("trouble")
          if not trouble.is_open() then
            trouble.open()
          end
          trouble.previous({ skip_groups = true, jump = false })
          trouble.next({ skip_groups = true, jump = true })
        end,
        desc = "First trouble item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            vim.cmd.cnext()
          end
        end,
        desc = "Next trouble/quickfix item",
      },
    },
    opts = {
      use_diagnostic_signs = true,
      auto_open = false,
      auto_close = true,
    },
  },

})

---- General settings
-- Disable the GUI cursor / use the terminal one.
vim.opt.guicursor = ''
-- Workaround for some broken plugins which set guicursor indiscriminately.
vim.cmd('autocmd OptionSet guicursor noautocmd set guicursor=')
-- Use the system clipboard.
vim.opt.clipboard = 'unnamedplus'

---- Tool config
-- Use a custom Python environment.
vim.g.neovim_python_env=HOME .. "/.config/nvim/.venv"
vim.g.python3_host_prog=vim.g.neovim_python_env .. "/bin/python3"

---- appearance
-- use 24-bit colors
vim.opt.termguicolors = true
--  Improve visual performance by not redrawing the screen when executing some commands
vim.opt.lazyredraw = true
-- show line numbers...
vim.opt.number = true
-- ... except when on quickfix
vim.cmd('autocmd FileType qf setlocal nonumber')

---- search
-- highlight the search phrase
vim.opt.hlsearch = true
-- highlight while typing the search phrase
vim.opt.incsearch = true
-- do case insensitive matching
vim.opt.ignorecase = true
-- override ignorecase if pattern contains upper case characters
vim.opt.smartcase = true

-- highlight the cursor line
-- XXX: using this + vertical splits is sometimes slow in (n)vim
vim.opt.cursorline = true
-- show the 'line,columns' on the bar
vim.opt.ruler = true
-- show matching brackets
vim.opt.showmatch = true

-- Always show the signcolumn, except for plugins configured below
vim.cmd('autocmd BufRead,BufNewFile * setlocal signcolumn=yes')

---- indent
-- copy indent from current line when starting a new line
vim.opt.autoindent = true
-- smart indent when starting a new line
vim.opt.smartindent = true
-- c-like indent, more strict than smartindent; do not use them simultanously
-- vim.opt.cindent = true

---- tabs
-- spaces a tab counts for
vim.opt.tabstop = 2
-- spaces inserted when hitting tab in Insert mode
vim.opt.expandtab = true
-- spaces inserted with reindent operations
vim.opt.shiftwidth = 2
-- spaces vim uses when hitting Tab in insert mode:
-- - if not equal to tabstop, vim will use a combination of tabs and spaces to make up the desired spacing
-- - if equal to tabstop, vimm will insert spaces/tabs for it, depending whether expandtab in on or off
vim.opt.softtabstop = 2

-- TODO: convert to lua equivalent
vim.cmd([[
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set text maximum width to 99 (100 including newline) - except when on quickfix
set textwidth=119
if exists('+colorcolumn')
  set colorcolumn=120
  autocmd FileType qf setlocal colorcolumn=
else
  autocmd BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>119v.\+', -1)
  " TODO remove matchadd on quickfix window for older versions of vim
endif

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

"----- highlight colors -----"
" change search highlight color
highlight Search cterm=NONE ctermfg=black ctermbg=darkyellow gui=NONE guifg=black guibg=darkyellow
" Reset bad spelling highlight, use only underline
highlight clear SpellBad
highlight SpellBad cterm=underline
" highlight trailing whitespace as errors
" highlight default link ExtraWhitespace Error
" highlight ExtraWhitespace ctermbg=darkred guibg=darkred
" match ExtraWhitespace /\s\+$/
" augroup HighlightWhitespace
" autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
" autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
" autocmd InsertLeave * match ExtraWhitespace /\s\+$/
" autocmd BufWinLeave * call clearmatches()
" augroup END

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

-- [[ Key mappings ]]

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

-- [[ telescope ]]

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

-- [[ treesitter ]]

-- Avoid installing the parsers on each start; NOTE: consider removing.
vim.opt.runtimepath:append("$HOME/.local/share/treesitter")

-- Configure a hocon filetype (mostly for Scala typessafe conf files).
local hocon_group = vim.api.nvim_create_augroup("hocon", { clear = true })
vim.api.nvim_create_autocmd(
  { 'BufNewFile', 'BufRead' },
  { group = hocon_group, pattern = '*/resources/*.conf', command = 'set ft=hocon' }
)

require('nvim-treesitter.configs').setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = 'all',
  -- ignore_install = { 'lua' },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  highlight = {
    enable = true,
    -- Disable slow treesitter highlight for large files
    disable = function(lang, buf)
      local max_filesize = 30 * 1024 -- 30 KB
      local ok, stats = pcall(vim.loop.fs_stat, api.nvim_buf_get_name(buf))
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
  indent = { enable = true },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  -- NOTE: copied from kickstart.nvim; TODO: understand its usefulness
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}
-- vim.opt.foldmethod = 'expr'
-- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
-- Disable folding at startup
-- vim.opt.foldenable = false

-- local ok, navic = pcall(require, 'nvim-navic')
-- if ok then
--   vim.o.winbar="%{%v:lua.require'nvim-navic'.get_location()%}"
-- end

-- [[ lsp ]]

-- Uncomment when debugging LSP servers.
-- vim.lsp.set_log_level("debug")

-- Signs not added when moving from init.vim to init.lua
-- sign define LspDiagnosticsSignError text=🔴
-- sign define LspDiagnosticsSignWarning text=🟠
-- sign define LspDiagnosticsSignInformation text=🔵
-- sign define LspDiagnosticsSignHint text=🟢


local servers = {
  bashls = {},
  clangd = {},
  helm_ls = {
    filetypes = { "helm" },
    cmd = { "helm_ls", "serve" },
  },
  -- lua_ls = {
  --   Lua = {
  --     workspace = { checkThirdParty = false },
  --     telemetry = { enable = false },
  --   },
  -- },
  marksman = {},
  pylsp = {
    cmd_env = {
      VIRTUAL_ENV=vim.g.neovim_python_env,
      PATH=vim.g.neovim_python_env .. "/bin/" .. ":" .. vim.env.PATH
    },
  },
  tsserver = {},
  terraformls = {},
  tflint = {},
  -- yamlls = {
  --   filetypes = { "yaml", "yaml.docker-compose" },
  --   settings = {
  --     yaml = {
  --       trace = {
  --         server = "verbose"
  --       },
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
}

-- Setup neovim lua configuration
-- require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require('mason-lspconfig')

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = lsp_on_attach,
      settings = servers[server_name],
      filetypes = servers[server_name].filetypes,
    }
  end
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require('cmp')
local luasnip = require('luasnip')
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

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
