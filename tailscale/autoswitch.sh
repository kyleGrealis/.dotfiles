#!/usr/bin/env bash
# Save this as /etc/NetworkManager/dispatcher.d/99-tailscale-autoswitch

# Make sure we have the required permissions
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 
   exit 1
fi

INTERFACE=$1
STATUS=$2

# Define known networks as array
KNOWN_NETS=("Go_Canes" "Canes_guest")
HOME_SCRIPT="/home/kyle/tailscale-home.sh"
PROTECT_SCRIPT="/home/kyle/tailscale-protect.sh"
LOG_FILE="/var/log/tailscale-autoswitch.log"

log() {
    echo "$(date): $*" >> "$LOG_FILE"
}

log "Network change detected: Interface=$INTERFACE Status=$STATUS"

# Replace the hardcoded interface check with:
WIFI_INTERFACE=$(nmcli -t -f DEVICE,TYPE device | grep ":wifi$" | cut -d: -f1)

# Only act on wifi connections that are activated
if [ "$STATUS" = "up" ] && [ "$INTERFACE" = "$WIFI_INTERFACE" ]; then
    # Get the current SSID
    CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
    log "Connected to SSID: $CURRENT_SSID"

    # Initialize a flag to check if the network is known
    KNOWN=false

    for NETWORK in "${KNOWN_NETS[@]}"; do
	if [ "$CURRENT_SSID" = "$NETWORK" ]; then
	    KNOWN=true
	    break
	fi
    done

    if [ "$KNOWN" = true ]; then
        log "Home network detected: $CURRENT_SSID. Running home script..."
        bash "$HOME_SCRIPT" >> "$LOG_FILE" 2>&1
    else
        log "Unknown network detected: $CURRENT_SSID! Running protect script..."
        bash "$PROTECT_SCRIPT" >> "$LOG_FILE" 2>&1
    fi
fi

exit 0
