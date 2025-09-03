# restart terminal session ----------------------
restart() {
	source "$HOME/.bashrc" 2>/dev/null || source "$HOME/.bashrc"
}

# git -------------------------------------------
alias gst='git status'
alias gpush='git push'
alias gpull='git pull'
alias gd='git diff -U0'

# This function takes in a list of files and a commit message
# Example: `gam . 'initial commit'` 
# Will add all files in the current directory and commit with the message 'initial commit'
gam() {
  for file in "${@:1:$#-1}"; do
    git add $file
  done
  git commit -m "${!#}"
}


# miscellaneous options -------------------------

# change directory AND list contents of the directory
cdl() {
	cd "$@";
	ls -alh;
}

# human readable file & directory
alias ls='ls -alh --color=auto'

# get date & time now
alias now='date +%F\ %T'

# get the weather
alias weather='curl wttr.in/Dallas?0'

# # GitHub repos backup to cloud
#alias backup='rsync -aH --delete --copy-unsafe-links --info=progress2 "$HOME/dev/" piCloud/kyle-backup/dev/'

alias code='nohup positron >/dev/null 2>&1 &'
alias rsync='rsync -azH --info=progress2'
