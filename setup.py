#!/usr/bin/env python3
"""Installs dotfiles from this repository."""

import argparse
import datetime
import errno
import filecmp
import logging
import platform
import os
import shutil
import subprocess
import sys
import tempfile
import urllib.request

from pathlib import Path

# Logging information.
logging.basicConfig(format='%(asctime)-23s %(levelname)-8s %(message)s')
LOG = logging.getLogger('')


def check_run():
    """Determine if the setup script is started from the root directory of the repository."""
    cmd = ['git', 'rev-parse', '--show-toplevel']
    directory = Path(subprocess.run(cmd, text=True, capture_output=True).stdout.rstrip())

    if directory != Path.cwd():
        LOG.error("This script must run from repository root directory.")
        sys.exit(errno.EPERM)


def get_os_type():
    """Determine OS system type in order to install OS-specific files."""
    return platform.system().lower()


def do_copy(src, dst, bak, append=False):
    """Copy file from src to dst, backing up to bak (if needed). If append is True, the file
    content from src is appended to (a possible existing) dst."""
    if not dst.is_file():
        os.makedirs(dst.parent, exist_ok=True)
        LOG.debug(f"Destination file does not exist: '{dst}'.")
        shutil.copy(src, dst)
        return
    if filecmp.cmp(src, dst, shallow=False):
        LOG.debug(f"Destination file is identical: '{dst}'.")
        return

    if bak:
        LOG.debug(f"Destination backup needed: '{dst}'.")
        os.makedirs(bak.parent, exist_ok=True)
        if bak.is_file():
            LOG.error(f"Backup already exists at path: '{bak}'.")
            sys.exit(errno.EEXIST)
        shutil.copy(dst, bak)
        LOG.info(f"Backup done: '{dst}'")

    if not append:
        shutil.copy(src, dst)
        LOG.debug("Append done: '{dst}'.")
    else:
        with dst.open('a') as dst_f:
            dst_f.write(src.open().read())
            LOG.debug("Write done: '{dst}'.")


def install(src_dir, dst_dir, bak_dir=None, append=False, add_dot=False):
    """Installs files from src_dir to dst_dir."""
    dot = '.' if add_dot else ''
    LOG.info(f"{'Install from':13s}: '{src_dir}'")
    LOG.info(f"{'to':13s}: '{dst_dir}'")
    if bak_dir:
        LOG.info(f"{'backup dir':13s}: '{bak_dir}'")
    if not src_dir.is_dir():
        LOG.warning("Source directory does not exist.")
        return
    for rel_path in [(Path(dirname) / filename).relative_to(src_dir)
                     for (dirname, _, filenames) in os.walk(src_dir)
                     for filename in filenames]:
        do_copy(
            src_dir / rel_path, dst_dir / (dot + str(rel_path)),
            bak_dir / rel_path if bak_dir else None, append)
    LOG.info("Install done.")


def git_clone(repo, base_dir, alt_name=None):
    """Clones a repository into the base_dir, changing the cloned directory name to alt_name if
    provided."""
    LOG.info(f"Clone repository {repo} into base dir {base_dir}")

    os.makedirs(base_dir, exist_ok=True)
    # TODO: optimize cloning.
    git_cmd = ['git', 'clone', '--depth=1', '--branch=master', repo]
    if alt_name:
        git_cmd.append(base_dir / alt_name)
    subprocess.run(git_cmd, cwd=base_dir)


def main():
    """Method to execute when script is called."""
    # Sanity check
    check_run()

    # Parser-specific arguments
    dst_dir = Path.home()
    parser = argparse.ArgumentParser(
        description="Installs dotfiles from this directory to a given directory.")
    parser.add_argument(
        '-d', '--directory', default=dst_dir,
        help="Installation directory; defaults to %(default)s.")
    parser.add_argument(
        '-v', '--verbose', action='store_true', help="Log this script actions at debug level.")
    parser.add_argument(
        '--skip-vim-plug-install', action='store_true', help="Do not call :PlugInstall in vim.")

    args = parser.parse_args()

    # Prepare install.
    LOG.setLevel(logging.DEBUG if args.verbose else logging.INFO)
    # Trying to avoid using colons in path names, so not using isoformat.
    now = datetime.datetime.now().strftime('%Y-%m-%d_%H%M%S')
    repo_dir = Path.cwd()
    dst_dir = Path(args.directory)
    aux_dir = Path(tempfile.mkdtemp(dir=repo_dir, prefix=f'aux_{now}_'))
    bak_dir = Path(tempfile.mkdtemp(dir=repo_dir, prefix=f'bak_{now}_'))

    # Retrieve dircolors.
    # TODO: Read https://github.com/trapd00r/LS_COLORS#zsh-integration-with-zplugin
    urllib.request.urlretrieve(
        'https://raw.github.com/trapd00r/LS_COLORS/master/LS_COLORS',
        aux_dir / 'dircolors')

    # Install oh-my-zsh and plugins/themes.
    git_clone('https://github.com/robbyrussell/oh-my-zsh.git', aux_dir)
    omz_custom_dir = aux_dir / 'oh-my-zsh' / 'custom'
    git_clone('https://github.com/romkatv/powerlevel10k.git', omz_custom_dir / 'themes')
    omz_plugins_dir = omz_custom_dir / 'plugins'
    git_clone('https://github.com/zsh-users/zsh-syntax-highlighting.git', omz_plugins_dir)
    git_clone('https://github.com/zsh-users/zsh-completions.git', omz_plugins_dir)
    git_clone('https://github.com/zsh-users/zsh-autosuggestions.git', omz_plugins_dir)
    git_clone(
            'https://github.com/MichaelAquilina/zsh-you-should-use.git',
            omz_plugins_dir, 'you-should-use')
    # TODO: wait for it to become a proper plugin.
    # git_clone('https://github.com/trapd00r/zsh-syntax-highlighting-filetypes', omz_plugins_dir)

    # Install bash-it.
    git_clone('https://github.com/Bash-it/bash-it.git', aux_dir)

    # Install *env.
    # TODO: Check if *env exists in the path and not from $HOME/.*env before cloning here and
    # abort/warn with a message asking to uninstall the system one.
    git_clone('https://github.com/pyenv/pyenv.git', aux_dir)
    git_clone('https://github.com/jenv/jenv.git', aux_dir)
    git_clone('https://github.com/rbenv/rbenv.git', aux_dir)
    rbenv_plugins_dir = aux_dir / 'rbenv' / 'plugins'
    # The plugins directory does not exist in the rbenv repository, add the repo name in the path.
    git_clone('https://github.com/rbenv/ruby-build.git', rbenv_plugins_dir / 'ruby-build')

    # Install all files in auxilary dir.
    install(repo_dir / 'common', aux_dir)
    install(repo_dir / get_os_type(), aux_dir, append=True)

    # Retrieve vim-plug.
    vim_plug_file = aux_dir / 'vim' / 'autoload' / 'plug.vim'
    os.makedirs(vim_plug_file.parent, exist_ok=True)
    urllib.request.urlretrieve(
        'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim',
        vim_plug_file)

    # Install files from auxiliary directory to destination.
    install(aux_dir, dst_dir, bak_dir=bak_dir, add_dot=True)

    if not args.skip_vim_plug_install:
        # Install vim plugins using vim-plug.
        status = subprocess.run(['vim', '+silent', '+PlugInstall', '+qall'])
        if status.returncode:
            LOG.warning("Vim plugin install failed. You might need to install additional tools.")

    # Cleanup.
    shutil.rmtree(aux_dir)
    if not bak_dir.is_dir():
        LOG.info("Backup was not needed.")
        shutil.rmtree(bak_dir, ignore_errors=True)
    else:
        LOG.info(f"Backup was saved to '{bak_dir}'.")

    return 0


if __name__ == "__main__":
    sys.exit(main())
