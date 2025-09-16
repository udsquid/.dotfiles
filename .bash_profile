# Locale
export LC_ALL='en_US.UTF-8'

# Set PATH, MANPATH, etc., for Homebrew.
if [[ $OSTYPE =~ darwin.* ]] && [[ -a /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# uv
export PATH="/Users/neil/.local/bin:$PATH"

# mysql
if [[ -d "/usr/local/opt/mysql-client/bin" ]]; then
    export PATH="/usr/local/opt/mysql-client/bin:$PATH"
fi

# defer interactive things to .bashrc
if [[ -f ~/.bashrc ]]; then
    . ~/.bashrc
fi
