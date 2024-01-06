# TODO items for this repo

- Config related
  - zsh:
    - Load CLI completions for tools.
      - Check a generic way for brew-installed tools.
      - `mise completions zsh`
      - `lefthook completion zsh`
      - `pandoc --bash-completion`
      - Gather a list of tools to use and how they load their completion.
  - Rust/cargo
    - Ensure ~/.cargo/bin in PATH
  - git: make sure delta is installed.
  - rtx
    - install the latest tools on setup.
  - get LS_COLORS from remote.

- Repository related
  - Check if other dotfiles solutions work better.
  - Symlink all config files
    - If not, then detect new files in folders like ~/.bin or similar.
  - Dockerize the setup/install for demo purposes.
  - Add a GHA workflow for validation.

- Install tools
  - treesitter
  - aoc-cli
  - npm install -g vmd
  - mise install
  - pipx and useful ones
