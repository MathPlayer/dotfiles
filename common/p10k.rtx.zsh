## OK, here’s where I am now. Thank you!
## No longer mixing concerns: oh-my-zsh plugin and p10k prompt hook
## rtx current 2>/dev/null so that prompt hook doesn’t leak missing tool warnings (rtx activate zsh handles that)
## Mutate POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS which by default includes asdf from p10k configure.
##
## https://gist.github.com/travismiller/7a22b3a1227a9d0ac3cc2d2b33921abd

# Powerlevel10k prompt segments for rtx
#
# https://github.com/romkatv/powerlevel10k
# https://github.com/jdxcode/rtx
# [Feature request: add segment for rtx](https://github.com/romkatv/powerlevel10k/issues/2212)
#
# Usage in ~/.zshrc:
#
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
# [[ -f ~/.p10k.rtx.zsh ]] && source ~/.p10k.rtx.zsh
#
() {
  function prompt_rtx() {
    local plugins=("${(@f)$(rtx current 2>/dev/null)}")
    local plugin
    for plugin in ${(k)plugins}; do
      local parts=("${(@s/ /)plugin}")
      local tool=${(U)parts[1]}
      local version=${parts[2]}
      # TODO: filter out what tools to show in a better way.
      if [[ $tool == "AWSCLI" ||
        $tool == "PYTHON" ||
        $tool == "NODEJS" ||
        $tool == "RUBY" ]]; then
        p10k segment -r -i "${tool}_ICON" -s $tool -t "$version"
      fi
    done
  }

  typeset -g POWERLEVEL9K_RTX_FOREGROUND=66
  typeset -g POWERLEVEL9K_RTX_DOTNET_CORE_FOREGROUND=134
  typeset -g POWERLEVEL9K_RTX_ELIXIR_FOREGROUND=129
  typeset -g POWERLEVEL9K_RTX_ERLANG_FOREGROUND=125
  typeset -g POWERLEVEL9K_RTX_FLUTTER_FOREGROUND=38
  typeset -g POWERLEVEL9K_RTX_GOLANG_FOREGROUND=37
  typeset -g POWERLEVEL9K_RTX_HASKELL_FOREGROUND=172
  typeset -g POWERLEVEL9K_RTX_JAVA_FOREGROUND=32
  typeset -g POWERLEVEL9K_RTX_JULIA_FOREGROUND=70
  typeset -g POWERLEVEL9K_RTX_LUA_FOREGROUND=32
  typeset -g POWERLEVEL9K_RTX_NODEJS_FOREGROUND=70
  typeset -g POWERLEVEL9K_RTX_PERL_FOREGROUND=67
  typeset -g POWERLEVEL9K_RTX_PHP_FOREGROUND=99
  typeset -g POWERLEVEL9K_RTX_POSTGRES_FOREGROUND=31
  typeset -g POWERLEVEL9K_RTX_PYTHON_FOREGROUND=37
  typeset -g POWERLEVEL9K_RTX_RUBY_FOREGROUND=168
  typeset -g POWERLEVEL9K_RTX_RUST_FOREGROUND=37

  # Substitute the default asdf prompt element
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=("${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/asdf/rtx}")
}
