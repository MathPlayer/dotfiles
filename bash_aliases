#
# ~/.bash_aliases
#
# This file contains user-specific aliases.
#

# enable color support of ls and also add handy aliases
if [[ -x "/usr/bin/dircolors" ]]; then
  test -r "~/.dircolors" && \
  eval "$(dircolors -b ~/.dircolors)" || \
  eval "$(dircolors -b)"

  # ls alias
  if ls --group-directories-first >/dev/null 2>&1; then
    alias ls='ls -hF --color=auto --group-directories-first'
  else
    alias ls='ls -hF --color=auto'
  fi

  # other color aliases
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# More ls aliases
alias l='ls -CF'
alias sl='ls'
alias LS='ls'
alias la='ls -A'
alias ll='ls -lF'
alias la='ls -A'
alias lla='ll -A'

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
