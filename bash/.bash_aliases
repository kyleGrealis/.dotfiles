# File system
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Smart cd with zoxide integration
zd() {
  # The 'z' command from zoxide is smart enough to handle these cases:
  # - No arguments -> home directory
  # - `-` -> previous directory
  # - A valid path -> that directory
  # - A query -> fuzzy find and jump
  z "$@"
}
alias cd="zd"


# Enhanced cdl function using smart navigation (yours + his)
cdl() {
    zd "$@"
    eza -lha --group-directories-first --icons=auto
}

open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Directory navigation
up() {
    # Go up N levels, but not above home directory. Defaults to 1.
    local count=${1:-1}
    local target="."
    for i in $(seq 1 $count); do
        target+="/.."
    done

    local final_dest
    final_dest=$(realpath "$target")

    if [[ "$final_dest" != "$HOME"* && "$final_dest" != "$HOME" ]]; then
        cdl "$HOME"
    else
        cdl "$target"
    fi
}


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
alias code='/usr/share/positron/bin/positron'
alias update-grub="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias copy='tee >(wl-copy)'
alias watch-gpu='watch -n 0.5 nvidia-smi'
alias ff='fastfetch'
