# restart terminal session ----------------------
alias restart='source ~/.bashrc'

# git -------------------------------------------
alias gst='git status'
alias gpush='git push'
alias gpull='git pull'

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

# # Tailscale
# vpn-status() {
#   bash "$HOME/bash-scripts/tailscale/vpn-status.sh"
# }

# # GitHub repos backup to cloud
# alias backup='rsync -aH --delete --copy-unsafe-links --info=progress2 "$HOME/dev/" piCloud/kyle-backup/dev/'

# WSL2 Positron alias
if grep -q microsoft /proc/version 2>/dev/null; then
    # alias code='DONT_PROMPT_WSL_INSTALL=1 GDK_SCALE=2 positron'
    echo "you're using windows"
else
	# alias code='positron'
fi
