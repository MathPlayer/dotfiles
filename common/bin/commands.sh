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
    . "$1"
  fi
}

# Tests if a command exists. Alias are ignored.
command_exists () {
  local OUTPUT=`command -v "$1" 2>&1`
  local STATUS=$!
  if [ ${status} -ne 0 ]; then
    return ${status}
  elif case ${OUTPUT} in alias*) true;; *) false;; esac; then
    unalias "$1"
    if `command -v "$1" 2>&1 > /dev/null`; then
      return 0
    else
      eval "${OUTPUT}"
      return 1
    fi
  else
    return 0
  fi
}


# Sets term's window title.
set_title () {
  echo -ne "\e]2;$@\a\e]1;$@\a"
}

# Sets the display for (Cygwin) X11 forwarding.
set_display_x11 () {
  export DISPLAY=:0.0
}
