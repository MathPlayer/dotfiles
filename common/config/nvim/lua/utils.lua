local M = {}

M.map = function(mode, keys, func, desc, extra_opts)
  extra_opts = extra_opts or {}
  if desc then
    extra_opts.desc = desc
  end
  vim.keymap.set(mode, keys, func, extra_opts)
end

return M
