# Feature request (for rtx, the same tool before renaming):
# https://github.com/romkatv/powerlevel10k/issues/2212
#
# Usage in ~/.zshrc:
#
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
# [[ -f ~/.p10k.mise.zsh ]] && source ~/.p10k.mise.zsh

() {
  function prompt_mise() {
    local plugins=("${(@f)$(mise current 2>/dev/null)}")
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

  typeset -g POWERLEVEL9K_MISE_FOREGROUND=66
  typeset -g POWERLEVEL9K_MISE_DOTNET_CORE_FOREGROUND=134
  typeset -g POWERLEVEL9K_MISE_ELIXIR_FOREGROUND=129
  typeset -g POWERLEVEL9K_MISE_ERLANG_FOREGROUND=125
  typeset -g POWERLEVEL9K_MISE_FLUTTER_FOREGROUND=38
  typeset -g POWERLEVEL9K_MISE_GOLANG_FOREGROUND=37
  typeset -g POWERLEVEL9K_MISE_HASKELL_FOREGROUND=172
  typeset -g POWERLEVEL9K_MISE_JAVA_FOREGROUND=32
  typeset -g POWERLEVEL9K_MISE_JULIA_FOREGROUND=70
  typeset -g POWERLEVEL9K_MISE_LUA_FOREGROUND=32
  typeset -g POWERLEVEL9K_MISE_NODEJS_FOREGROUND=70
  typeset -g POWERLEVEL9K_MISE_PERL_FOREGROUND=67
  typeset -g POWERLEVEL9K_MISE_PHP_FOREGROUND=99
  typeset -g POWERLEVEL9K_MISE_POSTGRES_FOREGROUND=31
  typeset -g POWERLEVEL9K_MISE_PYTHON_FOREGROUND=37
  typeset -g POWERLEVEL9K_MISE_RUBY_FOREGROUND=168
  typeset -g POWERLEVEL9K_MISE_RUST_FOREGROUND=37

  # Substitute the default asdf prompt element
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=("${POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS[@]/asdf/mise}")
}
