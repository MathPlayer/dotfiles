# My dotfiles repository

This repository keep track of all configuration files used on all major operating systems used (Windows, Linux, OSX).

## Prerequisites

You must have the following tools installed:

* git
* curl
* zsh
* vim or neovim
* Python 3 (>= 3.6).

## Installing

In order to install the dotfiles, run from the root directory of the repository the setup script:

    ./setup.py

For additional options availble check the help:

    ./setup.py --help

Note: The installation is supposed to be based only on standard Python libraries. In case the setup script is failing
because of an import, you can try to install the corresponding library.

## Additional tools

The configuration makes use of certain tools already installed. The ones I like the most:

- [bat](https://github.com/sharkdp/bat): cat with wings
- [exa](https://the.exa.website): modernized ls
- [rg](https://github.com/BurntSushi/ripgrep): modern and faster grep
- [rtx](https://github.com/jdxcode/rtx):
  manage multiple runtime version for tools (think of union of pyenv, rbenv, nodenv, etc.)
