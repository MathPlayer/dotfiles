#!/bin/bash

SCRIPT_NAME="$(basename $0)"
CRT_DIR="$(dirname $(readlink -f ${SCRIPT_NAME}))"
OLD_DIR="${CRT_DIR}/backup/$(date +"%F_%T_%N")"
EXCLUDES=(
"README.md"
"contributors.txt"
${SCRIPT_NAME}
)

mkdir -p ${OLD_DIR}
FILES=$(find "${CRT_DIR}" \
  -type f \
  -not -path "${CRT_DIR}/.git/*" \
  -not -path "${OLD_DIR}/*" \
  \( -iname "*" ! -iname ".*.swp" \) )
for filename in ${FILES}; do
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
  relative_file="${filename#${CRT_DIR}/}"
  home_file="${HOME}/.${relative_file}"
  echo "INSTALL ${filename} to"
  echo "        ${home_file}"
  if [ -f "${home_file}" ]; then
    diff -s "${home_file}" "${CRT_DIR}/${relative_file}" 2>&1 > /dev/null
    to_replace=$?
    if [[ 0 == ${to_replace} ]]; then
      echo "Identical file found"
      continue
    fi
    echo "BACKUP ${home_file} to"
    echo "       ${OLD_DIR}/${relative_file}"
    mkdir -p "$(dirname ${OLD_DIR}/${relative_file})"
    mv "${home_file}" "${OLD_DIR}/${relative_file}"
  fi
  if [[ 0 == ${to_replace} ]]; then
    continue
  fi
  mkdir -p "$(dirname ${home_file})"
  cp "${CRT_DIR}/${relative_file}" "${home_file}"
done

