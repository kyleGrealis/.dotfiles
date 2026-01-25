# Source aliases and functions
[ -f ~/.bash_aliases ] && source ~/.bash_aliases
[ -f ~/.bash_profile ] && source ~/.bash_profile

# Add custom PATH or other environment variables here if needed
export PATH="$HOME/.local/bin:$PATH"

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth:erasedups

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=10000

# custom prompt
PS1='\n\[\033[1;34m\]\W\[\033[0;35m\]$(parse_git_branch) \[\033[0m\]\n\[\033[0;32m\]\u@\h\[\033[0m\] >> '
. "$HOME/.cargo/env"

# add ble.sh: https://github.com/akinomyoga/ble.sh for instructions
# [[ $- == *i* ]] && source /usr/share/blesh/ble.sh
eval "$(zoxide init bash)"
eval "$(fnm env --use-on-cd)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# Ultimate Arch Cleanup
alias yeet='sudo pacman -Rs ninja; yay -Sc --noconfirm; sudo paccache -r; flatpak uninstall --unused; sudo journalctl --vacuum-time=2weeks; rm -rf ~/.cache/thumbnails/*'
alias kdererun='pkill -f kdeconnectd; (/usr/bin/kdeconnectd > /dev/null 2>&1 & disown)'
