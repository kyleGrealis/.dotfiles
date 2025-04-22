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
	ls -alhF;
}

# human readable file & directory
alias ls='ls -alh --color=auto'

# get date & time now
alias now='date +%F\ %T'

# get the weather
alias weather='curl wttr.in/Dallas?0'

# Tailscale
alias tailnet-up='sudo tailscale up --exit-node=100.125.173.109 --exit-node-allow-lan-access --accept-routes'
alias tailnet-down='sudo tailscale down'

vpn-status() {
  echo "🌐 Checking VPN status..."
  IP=$(curl -s ifconfig.me)
  echo "🔎 Public IP: $IP"

  # Set this to the actual home/public IP (e.g., from Pi5)
  HOME_IP="99.7.51.118"

  if [ "$IP" = "$HOME_IP" ]; then
    echo "✅ You are using Pi 5 as your exit node! 🛡️"
    echo "🧠 Traffic is being routed through home."
  else
    echo "❌ Not using Pi 5 as exit node."
    echo "⚠️ Traffic is likely exposed on current network."
  fi
}

vpn-whereami() {
  echo "🌍 Your IP: $(curl -s https://ipinfo.io/ip)"
  echo "📍 Location: $(curl -s https://ipinfo.io/city), $(curl -s https://ipinfo.io/region)"
  echo "🏢 ISP: $(curl -s https://ipinfo.io/org)"
}

