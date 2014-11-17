#!/bin/bash

# Declare global variables to use.
SCRIPT_NAME="$(basename $0)"
CRT_DIR="$(dirname $(readlink -f ${SCRIPT_NAME}))"
OLD_DIR="${CRT_DIR}/backup/$(date +"%F_%T_%N")"
EXCLUDES=(
"README.md"
"contributors.txt"
".gitmodules"
"bin/ssh-agent-init"
${SCRIPT_NAME}
)

# Create backup dir.
mkdir -p ${OLD_DIR}

# Get files to install.
FILES=$(find "${CRT_DIR}" \
  -type f \
  -not -path "${CRT_DIR}/putty_regs/*" \
  -not -path "${CRT_DIR}/.git/*" \
  -not -path "${CRT_DIR}/backup/*" \
  -not -path "${OLD_DIR}/*" \
  \( -iname "*" ! -iname ".*.swp" \) )

# Check the files to install.
for filename in ${FILES}; do
  # Skip excludes.
  to_replace=1
  for possible in "${EXCLUDES[@]}"; do
    if [[ "${CRT_DIR}/${possible}" == "${filename}" ]]; then
      to_replace=0
      break
    fi
  done
  if [[ 0 == ${to_replace} ]]; then
    echo "SKIP    ${filename}"
    continue
  fi

  # Check if the file already exists.
  relative_file="${filename#${CRT_DIR}/}"
  home_file="${HOME}/.${relative_file}"
  backup_file=
  if [ -f "${home_file}" ]; then
    # Do not backup identical files.
    diff -s "${home_file}" "${CRT_DIR}/${relative_file}" 2>&1 > /dev/null
    to_replace=$?
    if [[ 0 == ${to_replace} ]]; then
      echo "Identical file found: ${home_file}"
      continue
    fi

    # Backup different files with same name.
    backup_file="${OLD_DIR}/${relative_file}"
    mkdir -p "$(dirname ${OLD_DIR}/${relative_file})"
    mv "${home_file}" "${OLD_DIR}/${relative_file}"
  fi
  if [[ 0 == ${to_replace} ]]; then
    continue
  fi

  # Install new file.
  echo "INSTALL ${filename} to"
  echo "        ${home_file}"
  if [[ ! -z ${backup_file} ]]; then
    echo "BACKUP  ${backup_file}"
  fi
  mkdir -p "$(dirname ${home_file})"
  cp "${CRT_DIR}/${relative_file}" "${home_file}"
done
