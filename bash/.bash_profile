# .bash_profile for custom functions

# Git branch parsing for prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Watch the tailnet log in live time as autoswitching occurs
taillog () { tail -f /var/log/tailscale-autoswitch.log; }
. "$HOME/.cargo/env"
