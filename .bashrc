# bash
if [[ -f ~/.bashrc.local.pre ]]; then
    . ~/.bashrc.local.pre
fi

# locale
export LC_ALL='en_US.UTF-8'

# aliases
if [[ $OSTYPE =~ darwin.* ]]; then
    alias ls='ls -G'
elif [[ $OSTYPE =~ linux-gnu.* ]]; then
    alias ls='ls --color=always'
else
    echo "ERROR: not supported platform" >&2
    exit 1
fi

alias ll='ls -al'

# colors
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
DEFAULT=$(tput setaf 9)

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# pyenv
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# mysql
if [[ -d "/usr/local/opt/mysql-client/bin" ]]; then
    export PATH="/usr/local/opt/mysql-client/bin:$PATH"
fi

# my prompt
function get_nanosec() {
    if [[ $OSTYPE =~ darwin.* ]]; then
        echo $(gdate +%s.%3N)
    elif [[ $OSTYPE =~ linux-gnu.* ]]; then
        echo $(date +%s.%3N)
    else
        echo "ERROR: not supported platform" >&2
	exit 1
    fi
}

BASHTIME_FILE="/tmp/${USER}.bashtime.${BASHPID}"

function bashtime_save() {
    get_nanosec > "$BASHTIME_FILE"
}

function clean_up() {
    rm "$BASHTIME_FILE"
}

trap clean_up EXIT

function bashtime_diff() {
    if [[ ! -f "$BASHTIME_FILE" ]]; then
	bashtime_save
    fi

    local now=$(get_nanosec)
    local last=$(cat "$BASHTIME_FILE")
    printf "%.2f" $(echo "$now - $last" | bc)
}

bashtime_save			# init time file
PS0='$(bashtime_save)'
PS1='\
$(
    err=$?
    if (( $err == 0 )); then
        err_st="${err}"
    else
        err_st="\[$RED\]$err\[$WHITE\]"
    fi

    printf "%b:%b [%s|%b|%b]\$ " \
        "\[$GREEN\]\h\[$WHITE\]" \
        "\[$BLUE\]\W\[$WHITE\]" \
        "\t" \
        "\[$YELLOW\]$(bashtime_diff)\[$WHITE\]" \
        "$err_st"
)'

# vterm (for Emacs)
vterm_printf(){
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ] ); then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

vterm_prompt_end(){
    vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
}
PS1=$PS1'\[$(vterm_prompt_end)\]'

# bash
if [[ -f ~/.bashrc.local.post ]]; then
    . ~/.bashrc.local.post
fi
