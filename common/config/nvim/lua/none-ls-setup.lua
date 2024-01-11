local null_ls = require('null-ls')
local mason_registry = require('mason-registry')

if not mason_registry.is_installed('clang-format') then
  vim.cmd('MasonInstall clang-format')
end

null_ls.setup({
  -- debug = true,
  sources = {
    null_ls.builtins.formatting.clang_format,
  },
})
