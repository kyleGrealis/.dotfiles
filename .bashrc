
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
PS1='\e[1;32m[kyle-3nc0d3d] \W -$ \e[0m '

# colorized directories
export CLICOLOR=1

# miscellaneous
export icloud=/Library/Mobile\ Documents/com~apple~CloudDocs/

cdl() {
	cd "$@";
	ls -alhF;
}
