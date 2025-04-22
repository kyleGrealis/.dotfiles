#!/usr/bin/env bash

# Tailscale launcher for Ubuntu when not on home LAN and using Tailscale

# tailscale-protect.sh - Route all traffic through Pi5 exit node
# Usage: ./tailscale-protect.sh

PI5_IP="100.125.173.109"

echo "Enabling Tailscale exit node protection..."
sudo tailscale up --exit-node=$PI5_IP

#Add delay
#sleep 2

# Verify the change
STATUS=$(tailscale status)

if echo $STATUS | grep -q "; exit node;"; then
    echo "✅ Exit node protection enabled! All traffic now routes through your Tailnet."
else
    echo "❌ Something went wrong. Please check tailscale status."
fi

