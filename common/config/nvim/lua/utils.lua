return {
  HOME = os.getenv('HOME'),

  is_work_machine = os.getenv('MACHINE_TYPE') == 'work',

  map = function(mode, keys, func, desc, extra_opts)
    extra_opts = extra_opts or {}
    if desc then
      extra_opts.desc = desc
    end
    vim.keymap.set(mode, keys, func, extra_opts)
  end,
}

-- vim: ts=2 sts=2 sw=2 et
