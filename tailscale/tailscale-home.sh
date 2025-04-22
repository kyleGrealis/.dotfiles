#!/usr/bin/env bash

# Tailscale launcher for Ubuntu when on home LAN and using Tailscale

# tailscale-home.sh - Disable exit node routing
# Usage: ./tailscale-home.sh

echo "Disabling Tailscale exit node protection..."
sudo tailscale up --exit-node=""

# Verify the change
STATUS=$(tailscale status)

if echo $STATUS | grep -q "offers exit node"; then
    echo "✅ Exit node protection disabled! Traffic now routes normally."
else
    echo "❌ Something went wrong. Please check tailscale status."
fi
