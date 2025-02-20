# restart terminal session ----------------------
alias restart='source ~/.bashrc'

# git -------------------------------------------
alias gst='git status'
alias gau='git add --update' # only for modified & deleted files
alias ga='git add'           # add any files
alias gm='git commit -m'
alias gpush='git push'
alias gpull='git pull'

# this function takes in a list of files and a commit message
# `gam . 'initial commit'` will add all files in the current directory and commit with the message 'initial commit'
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
	ls -alhF;
}

# human readable file & directory
alias ls='ls -alh --color=auto'

# get date & time now
alias now='date +%F\ %T'

# get the weather
alias weather='curl wttr.in/Dallas?0'

# alias for Positron editor
alias code='/bin/positron'
