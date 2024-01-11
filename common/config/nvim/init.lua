local map = require('utils').map

-- Remap the LEADER key to Space before anything else.
map({'n', 'v'}, '<Space>', '<Nop>', 'Disable Space since it gets mapped as Leader.', { silent = true })
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('lazy-bootstrap')
require('lazy-setup')

require('options')
require('keymaps')

require('telescope-setup')
require('treesitter-setup')

require('lsp-setup')
require('cmp-setup')
require('none-ls-setup')

require('others-setup')

-- vim: ts=2 sts=2 sw=2 et
