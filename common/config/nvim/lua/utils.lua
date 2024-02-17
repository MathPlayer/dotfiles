return {
  HOME = os.getenv('HOME'),

  isWorkMachine = os.getenv('MACHINE_TYPE') == 'work',
  useGithubCopilot = os.getenv('USE_GITHUB_COPILOT') == 'true',
  useCodeium = os.getenv('USE_CODEIUM') == 'true',

  map = function(mode, keys, func, desc, extra_opts)
    extra_opts = extra_opts or {}
    if desc then
      extra_opts.desc = desc
    end
    vim.keymap.set(mode, keys, func, extra_opts)
  end,
}

-- vim: ts=2 sts=2 sw=2 et
