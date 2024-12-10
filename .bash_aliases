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

# have `rm` move to recycle bin and NOT permanently erase
function safe_rm() {
    local recursive=false
    local force=false
    local files=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -r|-R|--recursive) recursive=true ;;
            -f|--force) force=true ;;
            *) files+=("$1") ;;
        esac
        shift
    done
    
    # Check if we have files to process
    if [ ${#files[@]} -eq 0 ]; then
        echo "No files specified"
        return 1
    fi
    
    # Process each file
    for file in "${files[@]}"; do
        if [ ! -e "$file" ]; then
            echo "No such file or directory: $file"
            continue
        fi
        
        # If not force, ask for confirmation
        if [ "$force" = false ]; then
            read -p "Are you sure you want to move '$file' to the trash? (y/n) " REPLY
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                continue
            fi
        fi
        
        # Handle directories
        if [ -d "$file" ] && [ "$recursive" = false ]; then
            echo "Cannot remove '$file': Is a directory (use -r for directories)"
            continue
        fi
        
        if trash-put "$file"; then
            echo "Moved '$file' to trash"
        else
            echo "Failed to move '$file' to trash"
        fi
    done
}
alias rm='safe_rm'

# human readable file & directory
alias ls='ls -alh --color=auto'

# get date & time now
alias now='date +%F\ %T'

# get the weather
alias weather='curl wttr.in/Dallas?0'

# alias for Positron editor
alias code='/bin/positron'
