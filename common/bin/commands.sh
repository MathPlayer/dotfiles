#
# Utilities to use in shell configuration files and from CLI.
#

# Source a file if exists.
source_if_exists() {
  if [ -f "$1" ]; then
    . "$1"
  fi
}

# Tests if a command exists. Aliases are ignored.
command_exists() {
  OUTPUT="$(command -v "$1" 2>&1)"
  STATUS=$?
  if [ ${STATUS} -ne 0 ] || [ -z "${OUTPUT}" ]; then
    # "command" failed.
    return 1
  elif case ${OUTPUT} in alias*) true;; *) false;; esac; then
    # "command" reported an alias.
    unalias "$1"
    eval "command -v $1 2>&1 > /dev/null"
    STATUS=$?
    eval "${OUTPUT}"
  else
    # "command" reported a path.
    STATUS=0
  fi
  return ${STATUS}
}

# Echoes to stdout the path for a command. Aliases are ignored.
get_absolute_path() {
  OUTPUT="$(command -v "$1" 2>&1)"
  STATUS=$?
  if [ ${STATUS} -ne 0 ] || [ -z "${OUTPUT}" ]; then
    echo ""
  elif case ${OUTPUT} in alias*) true;; *) false;; esac; then
    # "command" reported an alias.
    unalias "$1"
    UNALIAS_OUTPUT="$(command -v "$1" 2>&1)"
    STATUS=$?
    eval "${OUTPUT}"
    if [ ${STATUS} -eq 0 ]; then
      echo "${UNALIAS_OUTPUT}"
    fi
  else
    echo "${OUTPUT}"
  fi
}

# Sets the display for (Cygwin) X11 forwarding.
set_display_x11 () {
  export DISPLAY=:0.0
}
