#!/bin/bash

SCRIPT_NAME="$(basename $0)"
CRT_DIR="$(dirname $(readlink -f ${SCRIPT_NAME}))"
OLD_DIR="${CRT_DIR}/backup"
mkdir -p ${OLD_DIR}
EXCLUDES=(
	"README.md"
	"contributors.txt"
	${SCRIPT_NAME}
)

FILES=$(find "${CRT_DIR}" \
	-type f \
	-not -path "${CRT_DIR}/.git/*" \
	-not -path "${OLD_DIR}/*" \
	\( -iname "*" ! -iname ".*.swp" \) )
for filename in ${FILES}; do
	found=0
	for possible in "${EXCLUDES[@]}"; do
		if [[ "${CRT_DIR}/${possible}" == "${filename}" ]]; then
			found=1
			break
		fi
	done
	if [[ "${found}" == "1" ]]; then
		echo "SKIP    ${filename}"
		continue
	fi
	relative_file="${filename#${CRT_DIR}/}"
	home_file="${HOME}/$(dirname ${relative_file})/.$(basename ${relative_file})"
	echo "INSTALL ${filename} to"
	echo "        ${home_file}"
	if [ -f "${home_file}" ]; then
		echo "BACKUP ${home_file} to"
		echo "       ${OLD_DIR}/${relative_file}"
		mkdir -p "$(dirname ${OLD_DIR}/${relative_file})"
		mv "${home_file}" "${OLD_DIR}/${relative_file}"
	fi
	mkdir -p "$(dirname ${home_file})"
	cp "${CRT_DIR}/${relative_file}" "${home_file}"
done

