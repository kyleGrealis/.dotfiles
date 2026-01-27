# .bash_profile for custom functions

# Git branch parsing for prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Fix `rm` / `rm -rf` to use trash-cli instead. Makes mistakes recoverable!
rm() {
  local args=()
  for arg in "$@"; do
    [[ "$arg" =~ ^-[rRfiv]+$ ]] || args+=("$arg")
  done
  trash-put "${args[@]}"
}

. "$HOME/.cargo/env"
