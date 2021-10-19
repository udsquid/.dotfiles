# completions
if [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]]; then
    . "/usr/local/etc/profile.d/bash_completion.sh"
fi
if [[ -r "/usr/local/etc/profile.d/docker.bash-completion" ]]; then
    . "/usr/local/etc/profile.d/docker.bash-completion"
fi

# defer interactive things to .bashrc
if [[ -f ~/.bashrc ]]; then
    . ~/.bashrc
fi
