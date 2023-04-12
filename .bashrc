
# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# add day & time to history input
HISTTIMEFORMAT='%m-%d %T  '

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# custom user prompt
PS1='\[\e[1;32m\][kyle-3nc0d3d] \W -$ \[\e[0m\] '

# colorized directories
export CLICOLOR=1

#####------------------------------------------------------------------
# miscellaneous
export icloud=/Library/Mobile\ Documents/com~apple~CloudDocs/
# colors for use inside echo and printf
export nc='\033[0m'              # No color
export black='\033[0;30m'        # Black
export red='\033[0;31m'          # Red
export green='\033[0;32m'        # Green
export yellow='\033[0;33m'       # Yellow
export blue='\033[0;34m'         # Blue
export purple='\033[0;35m'       # Purple
export cyan='\033[0;36m'         # Cyan
export white='\033[0;37m'        # White
# bold
export bblack='\033[1;30m'       # Black
export bred='\033[1;31m'         # Red
export bgreen='\033[1;32m'       # Greene
export byellow='\033[1;33m'      # Yellow
export bblue='\033[1;34m'        # Blue
export bpurple='\033[1;35m'      # Purple
export bcyan='\033[1;36m'        # Cyan
export bwhite='\033[1;37m'       # White

# change directory AND list contents of the directory
cdl() {
	cd "$@";
	ls -alhF;
}
