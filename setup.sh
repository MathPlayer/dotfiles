#!/bin/bash
#
# Setup the dotfiles into their place.
#

# Declare global variables.
readonly SCRIPT="$(basename "${BASH_SOURCE[0]}")"
readonly SRC_DIR="$(readlink -e "$(dirname "${BASH_SOURCE[0]}")")"
readonly BAK_DIR="$(mktemp -d -p "${SRC_DIR}" \
  -t "backup-$(date +%Y-%m-%d-%H-%M-%S)-XXXXXXX")"
DST_DIR=""
NO_BACKUP=true

# Source files based on operating system.
# INFO: a file should not be in both common and linux/windows directories.
readonly COMMON_DIR="${SRC_DIR}/common"
readonly LINUX_DIR="${SRC_DIR}/linux"
readonly WINDOWS_DIR="${SRC_DIR}/windows"

# Print the script usage.
usage() {
  echo
  echo "Usage: ${SCRIPT} [-h] [-d <destination_dir]"
  echo " -d    Set the destination directory to <destination_dir>."
  echo "       If the argument is specified, <destination_dir> need to be"
  echo "       an existing directory. If the argument is not specified,"
  echo "       the default is the home directory of the current user."
  echo " -h    Show this help message."
  exit 1
}

# Install files from a specified directory
install_files() {
  local src_dir="$1"
  local src_file=""
  local dst_file=""
  local bak_file=""

  cd "${src_dir}"
  local filenames=$(find . -type f | sed "s/.\///")
  cd -

  for filename in ${filenames}; do
    src_file="${src_dir}/${filename}"
    dst_file="${DST_DIR}/.${filename}"
    bak_file="${BAK_DIR}/${filename}"
    echo "Install file  ${src_file}"
    echo "          to  ${dst_file}"

    # Backup destination file if exists and is different than the source one.
    if [[ -f "${dst_file}" ]]; then
      cmp --silent "${src_file}" "${dst_file}"
      if [[ $? -ne 0 ]]; then
        NO_BACKUP=false
        echo "Save backup to ${bak_file}"
        mkdir -p "$(dirname "${bak_file}")"
        cp "${dst_file}" "${bak_file}"
      else
        echo "Identical file found, skipping it."
        continue
      fi
    fi
    mkdir -p "$(dirname "${dst_file}")"
    cp "${src_file}" "${dst_file}"

  done
}

# Get command line arguments
while getopts ":d:h" flag; do
  case ${flag} in
    d)
      DST_DIR="$(readlink -e "${OPTARG}")"
      if [[ ! -d "${DST_DIR}" ]]; then
        echo "Error: Destination is not a directory."
        usage
      fi
      ;;
    h)
      usage
      ;;
    *)
      echo >&2 "Unexpected getopts error: ${flag}"
      usage
      ;;
  esac
done

if [[ -z "${DST_DIR}" ]]; then
  echo "INFO:  No destination specified, defaulting to home directory."
  DST_DIR="${HOME}"
fi
readonly DST_DIR

echo "INFO:  Source      ${SRC_DIR}"
echo "INFO:  Destination ${DST_DIR}"
echo "INFO:  Backup      ${BAK_DIR}"

if [[ "${OSTYPE}" == "linux-gnu" ]]; then
  install_files "${COMMON_DIR}"
  install_files "${LINUX_DIR}"
elif [[ "${OSTYPE}" == "cygwin" ]]; then
  install_files "${COMMON_DIR}"
  install_files "${WINDOWS_DIR}"
else
  echo "No idea how to install files on this system."
  exit 1
fi

if [[ ${NO_BACKUP} == true ]]; then
  echo "INFO:  No files were saved for backup."
  rmdir "${BAK_DIR}"
fi
