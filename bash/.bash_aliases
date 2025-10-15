# File system
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Smart cd with zoxide integration
alias cd="zd"
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ "$1" = "-" ]; then
    builtin cd - && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}

# Enhanced cdl function using smart navigation (yours + his)
cdl() {
    zd "$@"
    eza -lha --group-directories-first --icons=auto
}

open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Directories
alias ..='cdl ..'
alias ...='cdl ../..'
alias ....='cdl ../../..'

# Tools
n() { if [ "$#" -eq 0 ]; then nvim .; else nvim "$@"; fi; }

# Git (enhanced with your additions)
alias g='git'
alias gst='git status'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'
alias gd='git diff -U0'
alias gpush='git push'
alias gpull='git pull'

# Custom git function for selective commits (yours)
gam() {
  for file in "${@:1:$#-1}"; do
    git add $file
  done
  git commit -m "${!#}"
}

# Utilities (yours)
restart() {
    source "$HOME/.bashrc" 2>/dev/null || source "$HOME/.bashrc"
}

alias now='date +%F\ %T'
alias weather='curl wttr.in/Dallas?0'
alias rsync='rsync -azH --info=progress2'
alias code='/usr/share/positron/bin/positron --disable-gpu'
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"
