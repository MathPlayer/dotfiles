# Check and use dircolors
function {
  local dircolors_command="dircolors"
  if gdircolors --version > /dev/null 2>&1; then
    dircolors_command="gdircolors"
  fi

  if [[ -x "/usr/bin/dircolors" ]]; then
    test -r "~/.dircolors" && \
    eval "$(dircolors -b ~/.dircolors)" || \
    eval "$(dircolors -b)"
  fi
}

# Check if grm is available and switch to it
if grm --version > /dev/null 2>&1; then
  alias rm="grm"
fi

# Check if gtar is available and switch to it
if gtar --version > /dev/null 2>&1; then
  alias tar="gtar"
fi

# ls alias compute
function {
  local EXEC=ls
  local FLAG_COLOR=""
  local FLAG_GROUP_DIRECTORIES_FIRST=""
  local FLAG_HUMAN_SIZE=""
  local FLAG_INDICATOR=""

  # Check if gls is available and switch to it
  if gls --version > /dev/null 2>&1; then
    EXEC=gls
  fi

  # Add color
  if ${EXEC} --color=auto >/dev/null 2>&1; then
    FLAG_COLOR="--color=auto"
  elif ${EXEC} -G >/dev/null 2>&1; then
    FLAG_COLOR="-G"
  fi

  # Human-readable size
  if ${EXEC} -lh >/dev/null 2>&1; then
    FLAG_HUMAN_SIZE="-h"
  fi

  # Add specific indicator after directory/socket/link/...
  if ${EXEC} -F >/dev/null 2>&1; then
    FLAG_INDICATOR="-F"
  fi

  if ${EXEC} --group-directories-first >/dev/null 2>&1; then
    FLAG_GROUP_DIRECTORIES_FIRST="--group-directories-first"
  fi

  local ls_command="${EXEC} ${FLAG_COLOR} ${FLAG_INDICATOR} ${FLAG_HUMAN_SIZE} ${FLAG_GROUP_DIRECTORIES_FIRST}"
  # More ls aliases
  alias ls=${ls_command}
  alias sl=${ls_command}
  alias LS=${ls_command}
  alias l=${ls_command}" -l"
  alias ll=${ls_command}" -l"
  alias la=${ls_command}" -A"
  alias la=${ls_command}" -A"
  alias lla=${ls_command}" -lA"
}

# Other color aliases
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'


# Default to human readable figures
alias df='df -h'
alias du='du -h'


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# List only users processes
alias myps="ps axo user,tty,ppid,pid,command | grep -vE \"grep|ps axo\" | grep -E \"(USER\s*PPID)|$USER\""
alias mypsa="ps aux | grep -vE \"grep|ps aux\" | grep -E \"(USER\s*PID)|$USER\""


# Exit less if the output is small enough for only one screen
alias less='less -F'


# Force showing all output using tail
alias ftail='tail -f -n+1'


# SSH with logging
alias logssh='ssh > >(tee ssh-$(date +"%Y-%m-%d-%H-%M").out) 2> >(tee ssh-$(date +"%Y-%m-%d-%H-%M").err >&2)'
