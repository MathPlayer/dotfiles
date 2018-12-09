#!/usr/bin/env python3

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
import zipfile

logging.basicConfig(format="%(asctime)-23s %(levelname)-8s %(message)s")
LOG = logging.getLogger("")
SHELLS = ["bash", "zsh"]


def check_run():
    """Determine if the setup script is started from the root directory of the repository."""
    cmd = ["git", "rev-parse", "--show-toplevel"]
    directory = subprocess.Popen(cmd, stdout=subprocess.PIPE).communicate()[0].rstrip()

    if directory.decode() != os.getcwd():
        LOG.error("This script must be run from repository root directory")
        sys.exit(errno.EPERM)


def get_os_type():
    """Determine OS system type in order to install OS-specific files."""
    return platform.system().lower()


def do_copy(src, dst, bak, rel, append=False):
    """Install file from src to dst, doing a backup to bak if needed and appending to dst if append
    param is true.
    """
    LOG.debug("on path: {}".format(rel))
    if not os.path.isfile(dst):
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        LOG.debug("Destination file does not exist")
        shutil.copy(src, dst)
        return
    if filecmp.cmp(src, dst, shallow=False):
        LOG.debug("Destination file is the same")
        return

    if bak:
        LOG.debug("Doing backup of destination")
        os.makedirs(os.path.dirname(bak), exist_ok=True)
        if os.path.isfile(bak):
            LOG.error("Backup already exists at path {}".format(bak))
            sys.exit(errno.EEXIST)
        shutil.copy(dst, bak)
        LOG.info("Backup done on file {}".format(dst))

    if not append:
        shutil.copy(src, dst)
    else:
        with open(dst, "a") as dst_f:
            dst_f.write(open(src, "r").read())


def install(src_dir, dst_dir, skipped_shells, bak_dir=None, append=False, add_dot=False):
    """Install files from src_dir to dst_dir."""
    dot = "." if add_dot else ""
    LOG.info("install from: {}".format(src_dir))
    LOG.info("          to: {}".format(dst_dir))
    if bak_dir:
        LOG.info("  backup dir: {}".format(bak_dir))
    if not os.path.isdir(src_dir):
        LOG.info("Source directory does not exist.")
        return
    for rel_path in [os.path.relpath(os.path.join(dirname, filename), src_dir)
                     for (dirname, _, filenames) in os.walk(src_dir)
                     for filename in filenames]:
        if any(map(rel_path.startswith, skipped_shells)):
            LOG.info("Skip shell file {}".format(rel_path))
        else:
            do_copy(
                os.path.join(src_dir, rel_path), os.path.join(dst_dir, dot + rel_path),
                os.path.join(bak_dir, rel_path) if bak_dir else None, append)
    LOG.info("done")
    LOG.info("----")


def main():
    """Method to execute when script is called."""
    # Sanity check
    check_run()

    # Parser-specific arguments
    dst_dir = os.path.expanduser("~")
    parser = argparse.ArgumentParser(
        description="Install dotfiles to a given directory")
    parser.add_argument(
        "-d", "--directory", default=dst_dir,
        help="directory to install into; default is the home directory, namingly '%(default)s'.")
    parser.add_argument(
        "-s", "--shell", default=[], action="append", choices=SHELLS,
        help="install shell-specific files only for the specified shells. Value must be one of "
             "%(choices)s. Can be provided multiple times. If not provided, all shell files are "
             "installed.")
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Show detailed info")

    args = parser.parse_args()
    skipped_shells = set(SHELLS) - set(args.shell) if args.shell else []

    # Prepare install
    LOG.setLevel(logging.DEBUG if args.verbose else logging.INFO)
    dst_dir = os.path.abspath(args.directory)
    aux_dir = tempfile.mkdtemp(
        dir=os.getcwd(), prefix="aux_{}".format(datetime.datetime.now().isoformat("_")))
    bak_dir = tempfile.mkdtemp(
        dir=os.getcwd(), prefix="bak_{}".format(datetime.datetime.now().isoformat("_")))

    # Create auxiliary directory with files to be installed
    install(os.path.abspath("common"), aux_dir, skipped_shells)
    install(os.path.abspath(get_os_type()), aux_dir, skipped_shells, append=True)

    # Retrieve vim-plug
    vim_plug_file = os.path.join(aux_dir, "vim", "autoload", "plug.vim")
    os.makedirs(os.path.dirname(vim_plug_file), exist_ok=True)
    urllib.request.urlretrieve(
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
        vim_plug_file)

    # If zsh is not skipped, install oh-my-zsh
    if "zsh" not in skipped_shells:
        oh_my_zsh_zip = os.path.join(aux_dir, "oh_my_zsh.zip")
        urllib.request.urlretrieve(
            "https://github.com/robbyrussell/oh-my-zsh/archive/master.zip",
            oh_my_zsh_zip)
        with zipfile.ZipFile(oh_my_zsh_zip) as zip_file:
            zip_file.extractall(aux_dir)
        os.rename(os.path.join(aux_dir, "oh-my-zsh-master"), os.path.join(aux_dir, "oh-my-zsh"))
        os.remove(oh_my_zsh_zip)

    # Install files from auxiliary directory to destination
    install(aux_dir, dst_dir, skipped_shells, bak_dir=bak_dir, add_dot=True)

    # Install vim plugins using vim-plug
    subprocess.check_call(["vim", "+silent", "+PlugInstall", "+qall"])

    # Cleanup
    shutil.rmtree(aux_dir)
    if not os.listdir(bak_dir):
        LOG.info("No backups were made.")
        shutil.rmtree(bak_dir, ignore_errors=True)
    else:
        LOG.info("Backups saved to {}".format(bak_dir))

    return 0


if __name__ == "__main__":
    sys.exit(main())
