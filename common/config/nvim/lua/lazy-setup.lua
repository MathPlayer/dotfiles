-- Setup lazy.nvim with all the plugins
local map = require('utils').map
local api = vim.api

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
        close_if_last_window = true,
        enable_git_status = true,
        default_component_configs = {
          git_status = {
            symbols = {
              -- Change type signs are redundant since the names are colored.
              -- Status type signs need some color changes.
              -- TODO: Check ':help neo-tree' for 'git' and adjust the highlight groups.
              added = '',
              deleted = '',
              modified = '',
              renamed = '',
            },
          },
        },
        filesystem = {
          group_empty_dirs = true,
        },
      }
    end
  },
  { 'nvim-tree/nvim-web-devicons', lazy = true },

  -- Tint the current / active window
  -- { 'levouh/tint.nvim', config = true },

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
      require('statuscol').setup({
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

  -- asciidoc
  { 'tigion/nvim-asciidoc-preview', ft = 'asciidoc' },

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

  {
    'nvimtools/none-ls.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
  },

  -- Autocompletion
  {
    'L3MON4D3/LuaSnip',
    version = 'v2.*',
    build = 'make install_jsregexp', -- optional
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',

      -- Other useful sources
      'hrsh7th/cmp-buffer',
      'FelipeLema/cmp-async-path',

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
      metals_config.on_attach = require('keymaps').on_attach
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

  {
    'Exafunction/codeium.nvim',
    cond = not require('utils').is_work_machine, -- Not yet vetoed by the company.
    dependencies = {
      'nvim-lua/plenary.nvim',
      'hrsh7th/nvim-cmp',
    },
    config = function () require('codeium').setup({}) end,
  },

  {
    'zbirenbaum/copilot.lua',
    -- Better to check if there's a token available. From work I have some, for personal purposes I
    -- won't get one.
    cond = require('utils').is_work_machine,
    event = 'InsertEnter',
    cmd = 'Copilot',
    config = function()
      require('copilot').setup({
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = false,
        },
      })
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    -- Better to check if there's a token available. From work I have some, for personal purposes I
    -- won't get one.
    cond = require('utils').is_work_machine,
    config = function()
      require('copilot_cmp').setup()
    end,
  },

})

-- vim: ts=2 sts=2 sw=2 et
