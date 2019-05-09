#
# Utilities to use in shell configuration files and from CLI.
#

export SCRIPT_ERR="ERROR: "
export SCRIPT_INF="INFO:  "
export SCRIPT_LOG="====== "
export SCRIPT_BAD_PARAMS=90

# Source a file if exists.
source_if_exists() {
  if [ -f "$1" ]; then
    source "$1"
  fi
}

# Tests if a command exists. Alias are ignored.
command_exists () {
  local OUTPUT=`command -v "$1" 2>&1`
  local STATUS=$?
  if [ ${STATUS} -ne 0 ] || [ -z "${OUTPUT}" ]; then
    # "command" failed.
    return 1
  elif case ${OUTPUT} in alias*) true;; *) false;; esac; then
    # "command" reported an alias.
    unalias "$1"
    eval "command -v "$1" 2>&1 > /dev/null"
    STATUS=$?
    eval "${OUTPUT}"
  else
    # "command" reported a path.
    STATUS=0
  fi
  return ${STATUS}
}


# Sets term's window title.
set_title () {
  echo -ne "\e]2;$@\a\e]1;$@\a"
}

# Sets the display for (Cygwin) X11 forwarding.
set_display_x11 () {
  export DISPLAY=:0.0
}
