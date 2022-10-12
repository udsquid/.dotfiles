# completions
if [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then
    . "/usr/local/etc/profile.d/bash_completion.sh"
fi
if [[ -r "/usr/local/etc/profile.d/docker.bash-completion" ]]; then
    . "/usr/local/etc/profile.d/docker.bash-completion"
fi

# Set PATH, MANPATH, etc., for Homebrew.
if [[ $OSTYPE =~ darwin.* ]] && [[ -a /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# defer interactive things to .bashrc
if [[ -f ~/.bashrc ]]; then
    . ~/.bashrc
fi
