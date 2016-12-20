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

logging.basicConfig(format="%(asctime)-23s %(levelname)-8s %(message)s")
log = logging.getLogger("")


def check_run():
    cmd = ["git", "rev-parse", "--show-toplevel"]
    log.info(">>> Run: {}".format(" ".join(cmd)))
    d = subprocess.Popen(cmd, stdout=subprocess.PIPE).communicate()[0].rstrip()

    if d != os.getcwd():
        log.error("This script must be run from repository root directory")
        sys.exit(errno.EPERM)


def get_submodules():
    cmd = ["git", "submodule", "update", "--init"]
    log.info(">>> Run: {}".format(" ".join(cmd)))
    child = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT)
    while True:
        line = child.stdout.readline()
        exitcode = child.poll()
        if not line:
            if exitcode is not None:
                break
            continue
        log.info(">>> " + line[:-1])
    child.wait()
    log.info("<<< End")


def mkdir_p(name):
    try:
        os.makedirs(name)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise


def do_copy(src, dst, bak, rel, append, dot):
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
    check_run()
    get_submodules()

    dst_dir = os.path.expanduser("~")
    parser = argparse.ArgumentParser(
            description="Install dotfiles to a given directory")
    parser.add_argument("-d", "--directory", default=dst_dir,
                        help="directory to install into; default is the home "
                             "directory, namingly '%(default)s'")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Show detailed info")
    args = parser.parse_args()

    log.setLevel(logging.DEBUG if args.verbose else logging.INFO)

    dst_dir = os.path.abspath(args.directory)
    aux_dir = tempfile.mkdtemp(
        dir=os.getcwd(),
        prefix="aux_{}".format(datetime.datetime.now().isoformat("_")))
    bak_dir = tempfile.mkdtemp(
        dir=os.getcwd(),
        prefix="bak_{}".format(datetime.datetime.now().isoformat("_")))

    install(os.path.abspath("common"), aux_dir)
    install(os.path.abspath(platform.system()), aux_dir, append=True)
    install(aux_dir, dst_dir, bak_dir=bak_dir, add_dot=True)

    shutil.rmtree(aux_dir)
    if not os.listdir(bak_dir):
        log.info("No backups were made.")
        shutil.rmtree(bak_dir, ignore_errors=True)
    else:
        log.info("Backups saved to {}".format(bak_dir))

    sys.exit(0)
