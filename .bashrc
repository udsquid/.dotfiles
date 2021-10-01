# locale
export LC_ALL='en_US.UTF-8'

# aliases
alias ls='ls -G'
alias ll='ls -al'

# colors
NORMAL='\e[0m'
BLACK='\e[30m'
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
WHITE='\e[37m'

# fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# mysql
export PATH="/usr/local/opt/mysql-client/bin:$PATH"

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
        echo -en "${GREEN}\h${NORMAL}:${BLUE}\W${NORMAL} [\t|$(bashtime_diff)|$?]\$ ";
    else
        echo -en "${GREEN}\h${NORMAL}:${BLUE}\W${NORMAL} [\t|$(bashtime_diff)|${RED}${err}${NORMAL}]\$ ";
    fi
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
