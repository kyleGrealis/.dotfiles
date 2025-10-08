#!/usr/bin/env bash

#=================================================================
# Fix SMB Mount Script
# Purpose: Update existing SMB mount to prevent boot/shutdown hangs
# Based on NixOS configuration robustness
#=================================================================

set -e

MOUNT_POINT="$HOME/piCloud"
SMB_CRED="$HOME/.smbcredentials"

echo "=== Fixing SMB Mount Configuration ==="
echo "This will update your fstab entry to prevent boot/shutdown hangs"
echo

# Check if piCloud mount exists in fstab
if ! grep -q "piCloud" /etc/fstab; then
    echo "ERROR: No existing piCloud mount found in /etc/fstab"
    echo "Run the original installer script first"
    exit 1
fi

# Backup current fstab
echo "Creating fstab backup..."
sudo cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d-%H%M%S)

# Remove old piCloud line from fstab
echo "Removing old SMB mount entry..."
sudo sed -i '/piCloud/d' /etc/fstab

# Add new robust mount line with NixOS-style timeouts
echo "Adding robust SMB mount configuration..."
ROBUST_FSTAB_LINE="//100.125.173.109/piCloud $MOUNT_POINT cifs credentials=$SMB_CRED,uid=1000,gid=1000,vers=3.0,nofail,_netdev,x-systemd.automount,x-systemd.requires=network-online.target,x-systemd.idle-timeout=300,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s 0 0"

echo "$ROBUST_FSTAB_LINE" | sudo tee -a /etc/fstab > /dev/null

# Ensure the unmount service exists and is enabled
echo "Checking cifs-umount service..."
if [ -f /etc/systemd/system/cifs-umount.service ]; then
    echo "Unmount service already exists"
else
    echo "Creating unmount service..."
    
    UNMOUNT_SERVICE="[Unit]
Description=Unmount CIFS shares before shutdown
DefaultDependencies=no
Before=network.target shutdown.target reboot.target halt.target
Conflicts=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c \"umount -f $MOUNT_POINT || true\"
TimeoutSec=10

[Install]
WantedBy=shutdown.target reboot.target halt.target"

    echo "$UNMOUNT_SERVICE" | sudo tee /etc/systemd/system/cifs-umount.service > /dev/null
    sudo systemctl daemon-reload
    sudo systemctl enable cifs-umount.service
fi

# Unmount if currently mounted, then remount with new settings
echo "Applying new mount configuration..."
sudo umount "$MOUNT_POINT" 2>/dev/null || true
sudo systemctl daemon-reload
sudo mount -a

# Verify mount worked
if mountpoint -q "$MOUNT_POINT"; then
    echo "SUCCESS: SMB mount updated and working"
    echo "Mount point: $MOUNT_POINT"
    echo "Configuration now includes:"
    echo "  - 5 second device/mount timeouts"
    echo "  - 5 minute idle timeout"
    echo "  - Network dependency handling"
    echo "  - Boot failure protection (nofail)"
else
    echo "WARNING: Mount not active, but configuration updated"
    echo "The mount will activate automatically when accessed"
fi

echo
echo "Your SMB mount is now configured like your NixOS system"
echo "This should prevent boot/shutdown hangs"
