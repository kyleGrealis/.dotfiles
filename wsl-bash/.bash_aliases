# restart terminal session ----------------------
alias restart='source ~/.bashrc'

# git -------------------------------------------
alias ga='git add'
alias gd='git diff -U0'
alias gpull='git pull'
alias gpush='git push'
alias gst='git status'

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

# WSL2 Positron alias
alias code='DONT_PROMPT_WSL_INSTALL=1 GDK_SCALE=2 positron'
alias rst='DONT_PROMPT_WSL_INSTALL=1 GDK_SCALE=2 rstudio'
