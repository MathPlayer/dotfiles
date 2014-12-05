#!/bin/bash

export SCRIPT_ERR="ERROR: "
export SCRIPT_INF="INFO:  "
export SCRIPT_LOG="====== "
export SCRIPT_BAD_PARAMS=90
export SSH_AUTH_SOCK="${HOME}/.ssh-socket"

# Test if a command exists.
command_exists () {
  test_command="$1"
  command -v "${test_command}" > "/dev/null" 2>&1
  status=$?
  if [[ "${status}" -ne "0" ]]; then
    echo >&2 "${SCRIPT_ERR} Command '${test_command}' does not exist."
    return ${status}
  fi

  return ${status}
}

# Set window title.
set_title () {
  echo -ne "\e]2;$@\a\e]1;$@\a"
}

# Set custom terminal prompt.
set_prompt () {
  local BLACK="\[\033[0;30m\]"
  local BLUE="\[\033[0;34m\]"
  local GREEN="\[\033[0;32m\]"
  local CYAN="\[\033[0;36m\]"
  local RED="\[\033[0;31m\]"
  local PURPLE="\[\033[0;35m\]"
  local BROWN="\[\033[0;33m\]"
  local LIGHT_GRAY="\[\033[0;37m\]"
  local DARK_GRAY="\[\033[1;30m\]"
  local LIGHT_BLUE="\[\033[1;34m\]"
  local LIGHT_GREEN="\[\033[1;32m\]"
  local LIGHT_CYAN="\[\033[1;36m\]"
  local LIGHT_RED="\[\033[1;31m\]"
  local LIGHT_PURPLE="\[\033[1;35m\]"
  local YELLOW="\[\033[1;33m\]"
  local WHITE="\[\033[1;37m\]"
  export PS1="${GREEN}\u${LIGHT_GRAY}@${GREEN}\H ${CYAN}\w${LIGHT_GRAY} $ "
}

# Set display for Cygwin X11 forwarding.
set_display_x11 () {
  export DISPLAY=:0.0
}

# Autocomplete for ssh hosts from known files:
# ~/.ssh/known_hosts and
# ~/.ssh/config
_complete_ssh_hosts () {
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  comp_ssh_hosts=`cat ~/.ssh/known_hosts | \
    cut -f 1 -d ' '        | \
    sed -e s/,.*//g        | \
    grep -v ^#             | \
    uniq                   | \
    grep -v "\[" ;
  cat ~/.ssh/config      | \
    grep "^Host"           | \
    awk '{print $2}'
  `
  COMPREPLY=( $(compgen -W "${comp_ssh_hosts}" -- $cur))
  return 0
}

ssh_agent_init () {
  # Start a ssh-agent if one is not already started
  ssh-add -l >/dev/null 2>&1
  if [ $? = 2 ]; then
    # No ssh-agent running
    rm -rf ${SSH_AUTH_SOCK}
    # >| allows output redirection to over-write files if no clobber is set
    ssh-agent -a ${SSH_AUTH_SOCK} >| "/tmp/.ssh-script"
    source "/tmp/.ssh-script"
    rm "/tmp/.ssh-script"
  fi
}

ssh_agent_add_keys () {
  # Run ssh_agent_init just to be sure we have the ssh-agent running
  ssh_agent_init

  # Add all new keys
  existing_keys=$(ssh-add -l | cut -f 3 -d ' ')
  for key in $(find "${HOME}/.ssh" -type f -name "*.pub"); do
    flag=0
    for existing_key in ${existing_keys}; do
      if [[ ${existing_key} == ${key%.pub} ]]; then
        flag=1
        break
      fi
    done

    if [[ "${flag}" -eq "1" ]]; then
      continue
    fi

    echo "${SCRIPT_LOG} Adding ssh key ${key%.pub}"
    ssh-add ${key%.pub}
  done
}
