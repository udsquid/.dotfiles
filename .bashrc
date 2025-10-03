# Only execute in interactive shells
case $- in
    *i*) ;;
    *) return;;
esac

# Pre-load custom user settings
if [[ -f ~/.bashrc.local.pre ]]; then
    . ~/.bashrc.local.pre
fi

# Color variables (safe tput check for different TERM)
if tput colors >/dev/null 2>&1; then
  BLACK=$(tput setaf 0)
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  MAGENTA=$(tput setaf 5)
  CYAN=$(tput setaf 6)
  WHITE=$(tput setaf 7)
  DEFAULT=$(tput sgr0)
else
  BLACK=; RED=; GREEN=; YELLOW=; BLUE=; MAGENTA=; CYAN=; WHITE=; DEFAULT=
fi

# Aliases
if [[ $OSTYPE =~ darwin.* ]]; then
    alias ls='ls -G'
elif [[ $OSTYPE =~ linux-gnu.* ]]; then
    alias ls='ls --color=always'
else
    echo "WARNING: Unknown platform ($OSTYPE), ls alias not set." >&2
fi

alias ll='ls -al'

# Load custom aliases if present
if [[ -f ~/.bash_aliases ]]; then
    . ~/.bash_aliases
fi

if [[ -f ~/.bash_aliases.local ]]; then
    . ~/.bash_aliases.local
fi

# Completions (dynamically detect Homebrew path: /opt/homebrew or /usr/local)
if command -v brew >/dev/null 2>&1; then
  _BREW_PREFIX="$(brew --prefix)"
  if [[ -r "$_BREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
    . "$_BREW_PREFIX/etc/profile.d/bash_completion.sh"
  elif [[ -r "$_BREW_PREFIX/etc/bash_completion" ]]; then
    . "$_BREW_PREFIX/etc/bash_completion"
  fi
fi

# Docker completion (adjust path as needed)
if [[ -r "/usr/local/etc/profile.d/docker.bash-completion" ]]; then
  . "/usr/local/etc/profile.d/docker.bash-completion"
fi

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Prompt
PS1='\[$GREEN\]\h:\[$BLUE\]\W\[$WHITE\]$ '

# Post-load custom user settings
if [[ -f ~/.bashrc.local.post ]]; then
    . ~/.bashrc.local.post
fi
