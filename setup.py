#!/usr/bin/env python

import argparse
import datetime
import errno
import filecmp
import hashlib
import itertools
import logging
import platform
import os
import shutil
import subprocess
import sys
import tempfile
import urllib

logging.basicConfig(format="%(asctime)-23s %(levelname)-8s %(message)s")
log = logging.getLogger("")


def check_run():
    ''' Determine if the setup script is started from the root directory
        of the repository.
    '''
    cmd = ["git", "rev-parse", "--show-toplevel"]
    log.info(">>> Run: {}".format(" ".join(cmd)))
    d = subprocess.Popen(cmd, stdout=subprocess.PIPE).communicate()[0].rstrip()

    if d != os.getcwd():
        log.error("This script must be run from repository root directory")
        sys.exit(errno.EPERM)


def get_os_type():
    ''' Determine OS system type in order to install OS-specific files.
    '''
    return platform.system().lower()


def mkdir_p(name):
    ''' Try to create a path of directories without throwing an error if the
        path already exists.
    '''
    try:
        os.makedirs(name)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise


def do_copy(src, dst, bak, rel, append, dot):
    ''' Install file from src/rel to dst/dot + rel, doing a backup to bak/rel
        if needed and appending to destination if append param is true.
    '''
    log.debug("on path: {}".format(rel))
    src = os.path.join(src, rel)
    dst = os.path.join(dst, dot + rel)
    if not os.path.isfile(dst):
        mkdir_p(os.path.dirname(dst))
        log.debug("Destination file does not exist")
        shutil.copy(src, dst)
        return
    if filecmp.cmp(src, dst, shallow=False):
        log.debug("Destination file is the same")
        return

    if bak:
        log.debug("Doing backup of destination")
        bak = os.path.join(bak, dot + rel)
        mkdir_p(os.path.dirname(bak))
        if os.path.isfile(bak):
            shutil.copy(bak, bak+bak[-1])
        shutil.copy(dst, bak)
        log.info("Backup done on file {}".format(dst))

    if not append:
        shutil.copy(src, dst)
    else:
        with open(dst, "a") as f:
            f.write(open(src, "r").read())
    return True


def install(src_dir, dst_dir, bak_dir=None, append=False, add_dot=False):
    ''' Install files from src_dir to dst_dir.
    '''
    dot = "." if add_dot else ""
    log.info("install from: {}".format(src_dir))
    log.info("          to: {}".format(dst_dir))
    if bak_dir:
        log.info("  backup dir: {}".format(bak_dir))
    if not os.path.isdir(src_dir):
        log.info("Source directory does not exist.")
        return None
    for rel_path in [os.path.relpath(os.path.join(dirname, filename), src_dir)
                     for (dirname, _, filenames) in os.walk(src_dir)
                     for filename in filenames]:
        do_copy(src_dir, dst_dir, bak_dir, rel_path, append, dot)
    log.info("done")
    log.info("----")


if __name__ == "__main__":
    # Sanity check
    check_run()

    # Parser-specific arguments
    dst_dir = os.path.expanduser("~")
    parser = argparse.ArgumentParser(
            description="Install dotfiles to a given directory")
    parser.add_argument("-d", "--directory", default=dst_dir,
                        help="directory to install into; default is the home "
                             "directory, namingly '%(default)s'")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Show detailed info")
    args = parser.parse_args()

    # Prepare install
    log.setLevel(logging.DEBUG if args.verbose else logging.INFO)
    dst_dir = os.path.abspath(args.directory)
    aux_dir = tempfile.mkdtemp(
        dir=os.getcwd(),
        prefix="aux_{}".format(datetime.datetime.now().isoformat("_")))
    bak_dir = tempfile.mkdtemp(
        dir=os.getcwd(),
        prefix="bak_{}".format(datetime.datetime.now().isoformat("_")))

    # Create auxiliary directory with files to be installed
    install(os.path.abspath("common"), aux_dir)
    install(os.path.abspath(get_os_type()), aux_dir, append=True)

    # Install files from auxiliary directory to destination
    install(aux_dir, dst_dir, bak_dir=bak_dir, add_dot=True)

    # Custom install to destination for vim-plug and all vim plugins
    vim_plug_file = os.path.join(aux_dir, "vim", "autoload", "plug.vim")
    mkdir_p(os.path.dirname(vim_plug_file))
    urllib.urlretrieve(
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim",
        vim_plug_file)
    subprocess.check_call(["vim", "+silent", "+PlugInstall", "+qall"])

    # Cleanup
    shutil.rmtree(aux_dir)
    if not os.listdir(bak_dir):
        log.info("No backups were made.")
        shutil.rmtree(bak_dir, ignore_errors=True)
    else:
        log.info("Backups saved to {}".format(bak_dir))

    sys.exit(0)
