#!/usr/bin/env python

from os.path import splitext as spext
from sys import argv


COMMENT_MAPPING = {
    '.scala': ['/*', '*/'],
    '.sbt': ['/*', '*/'],
    '.cpp': ['/*', '*/'],
    '.sh': ['#', '#']
}


def read_file(filename):
    with open(filename) as f:
        lines = f.readlines()
    return lines


def update_file(lines, start, end):
    if not lines[0].startswith(start):
        return lines

    for i, line in enumerate(lines):
        if line.strip().endswith(end):
            break
    i += 1

    while not lines[i].strip():
        i += 1

    return lines[i:]


def write_file(filename, lines):
    with open(filename, 'w') as f:
        f.writelines(lines)


def remove_comment_at_start(filename):
    extension = spext(filename)[-1]
    if extension not in COMMENT_MAPPING:
        return
    start, end = COMMENT_MAPPING[extension]

    lines = read_file(filename)
    lines = update_file(lines, start, end)
    write_file(filename, lines)


if __name__ == '__main__':
    for arg in argv:
        remove_comment_at_start(arg)
