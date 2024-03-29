#!/usr/bin/env python3
"""Installs dotfiles from this repository."""

import argparse
import datetime
import errno
import filecmp
import logging
import os
import platform
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


def get_os():
    """Determine the OS system type."""
    return platform.system().lower()


def do_copy(src, dst, bak, append=False):
    """Copy file from src to dst, backing up to bak (if needed).
    If append is True, the file content from src is appended to dst."""

    if not dst.is_file():
        os.makedirs(dst.parent, exist_ok=True)
        LOG.debug(f"Destination file does not exist: '{dst}'.")
        shutil.copy(src, dst, follow_symlinks=False)
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
        LOG.debug(f"Append done: '{dst}'.")
    else:
        with dst.open('a') as dst_f:
            dst_f.write(src.open().read())
            LOG.debug(f"Write done: '{dst}'.")


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


def git_pull_or_clone(repo, base_dir, alt_name=None):
    """Updates a repository into the base_dir, changing the directory name to alt_name if provided.
    If the repository exists, it pulls the latest changes, otherwise it clones it."""

    dst_dir = base_dir / alt_name if alt_name is not None else base_dir / Path(repo).stem
    os.makedirs(dst_dir, exist_ok=True)
    p = subprocess.run(['git', 'remote', 'get-url', 'origin'], cwd=dst_dir, capture_output=True)
    if not p.stderr and p.stdout.strip().decode('UTF-8') == repo:
        LOG.info(f"Pull repository {repo} into {dst_dir}")
        subprocess.run(['git', 'pull'])
    else:
        LOG.info(f"Clone repository {repo} into {dst_dir}")
        subprocess.run(['git', 'clone', '--depth=1', repo, dst_dir], cwd=base_dir)


def download_file(remote, local):
    """Download a file from the remote URL to the local Path object."""
    try:
        urllib.request.urlretrieve(remote, local)
    except urllib.request.URLError as e:
        LOG.warning(f"Could not retrieve {remote} to {local}: {e}")


def get_dependencies(deps_dir):
    """Updates all dependencies used by dotfiles using deps_dir as a base directory."""

    # Get the zsh plugin manager.
    git_pull_or_clone('https://github.com/jandamm/zgenom.git', deps_dir)


def main():
    """Method to execute when script is called."""

    check_run()

    # Parser-specific arguments
    dst_dir = Path.home()
    parser = argparse.ArgumentParser(
        description="Installs dotfiles from this directory to a given directory.")
    parser.add_argument(
        '-d', '--directory', default=dst_dir,
        help="Installation directory; defaults to %(default)s.")
    parser.add_argument(
        '-v', '--verbose', action='store_true',
        help="Log this script actions at debug level.")
    parser.add_argument(
        '-o', '--offline', action='store_true',
        help="Run in offline-mode, skipping any online actions.")
    parser.add_argument(
        '--skip-nvim-setup', action='store_true',
        help="Skip installing neovim plugins.")

    args = parser.parse_args()

    # Prepare install.
    LOG.setLevel(logging.DEBUG if args.verbose else logging.INFO)

    # Use a non-ISO format to avoid colons in path names.
    now = datetime.datetime.now().strftime('%Y-%m-%d_%H%M%S')
    repo_dir = Path.cwd()
    dst_dir = Path(args.directory)
    aux_dir = Path(tempfile.mkdtemp(dir=repo_dir, prefix=f'aux_{now}_'))
    bak_dir = Path(tempfile.mkdtemp(dir=repo_dir, prefix=f'bak_{now}_'))

    # Update all dependencies.
    deps_dir = repo_dir / '.deps'
    if not args.offline:
        get_dependencies(deps_dir)

    # Merge dotfiles in an auxiliary directory.
    install(repo_dir / 'common', aux_dir)
    install(repo_dir / get_os(), aux_dir, append=True)

    # Install all files.
    install(deps_dir, dst_dir, add_dot=True)
    install(aux_dir, dst_dir, bak_dir=bak_dir, add_dot=True)

    # Setup neovim.
    if not args.offline and not args.skip_nvim_setup:
        LOG.info("Install neovim plugins")
        nvim_setup_cmd = ['nvim', '--headless', '+Lazy! sync', '+qall']
        try:
            status = subprocess.run(nvim_setup_cmd)
            if status.returncode:
                LOG.warning(f"Installing neovim plugins failed (return code {status.returncode}).")
        except OSError as e:
            LOG.warning(f"Installing neovim plugins failed: {e.strerror}")

    # Cleanup.
    shutil.rmtree(aux_dir)
    if any(os.scandir(bak_dir)):
        LOG.info(f"Backup was saved to '{bak_dir}'.")
    else:
        LOG.info("Backup was not needed.")
        shutil.rmtree(bak_dir, ignore_errors=True)

    return 0


if __name__ == "__main__":
    sys.exit(main())
