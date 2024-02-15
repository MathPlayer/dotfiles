#!/usr/bin/env python3

# Find all duplicate binary files in PATH.

import os


def print_duplicates():

    executables = {}
    for path in os.getenv('PATH').split(':'):
        if not os.access(path, os.X_OK) or not os.path.isdir(path):
            continue
        print(f"DEBUG: looking into {path}")
        for file in os.listdir(path):
            full_path = os.path.join(path, file)
            if not os.access(full_path, os.X_OK) or not os.path.isfile(full_path):
                continue
            if file in executables:
                executables[file].append(full_path)
            else:
                executables[file] = [full_path]

    duplicates = {file: paths for file, paths in executables.items() if len(paths) > 1}
    if not duplicates:
        print("No binaries with duplicates.")
        return
    for file, paths in duplicates.items():
        print(file)
        for path in paths:
            print(f"- {path}")
        print()
    print(f"Total: {len(duplicates)} binaries with duplicates.")


if __name__ == "__main__":
    print_duplicates()
