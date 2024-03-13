# TODO items for this repo


- Config related
  - zsh:
    - Load CLI completions for tools.
      - Check a generic way for brew-installed tools.
      - `brew shellenv`
      - `mise completions zsh`
      - `lefthook completion zsh`
      - `pandoc --bash-completion`
      - Gather a list of tools to use and how they load their completion.
  - Rust/cargo
    - Ensure ~/.cargo/bin in PATH
  - git
    - make sure delta is installed.
    - set up git commit signing OR at least document the steps.
  - rtx
    - install the latest tools on setup.
  - wezterm:
    - terminfo download/setup as mentioned in the comment (see config.term).
    - config for windows/panels/...
  - bat
    - Change theme dynamically based on the system theme/appearance.
      For now, the change is handled through zshrc aliases. For macOS, you could use:

      ```sh
      if [[ $(defaults read -g AppleInterfaceStyle 2&>/dev/null) == "Dark" ]]; then
        echo "Theme: Dark"  # set dark theme, etc.
      else
        echo "Theme: Light" # set light theme, etc.
      fi
      ```
    - Create cheatsheet with bat usage from: <https://github.com/sharkdp/bat?tab=readme-ov-file>

  - arkenfox
    - set/update the user.js config for firefox and/or thunderbird

- Repository related
  - Switch to stow or dotbot.
    - Symlink all config files
  - Detect new files in folders like ~/.bin or similar.
  - Dockerize the setup/install for demo purposes.
  - Add a GHA workflow for validation.

- Machine setup:
  - shell:
    - tools:
      - mise + run `mise install` based on this repository's config.
      - vivid (os)
      - cmake (mise, os)
      - direnv (os)
      - bat (os)
      - eza (os)
      - fd (os)
      - jq (os)
      - ripgrep (os)
      - entr (os)
      - nmap
        - maybe not needed
      - (macOS) coreutils
        - maybe better? (g) sed/mkdir/etc.
  - Neovim:
    - Create Python virtualenv + install requirements
    - More tooling, including LSP servers that might be needed to be installed manually.
  - pipx and useful ones

- Others
  - aoc-cli
  - npm install -g vmd
  - hyperfine (os): benchmark shell commands, including zsh startup time.
