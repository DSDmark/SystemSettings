#!/bin/bash

# --- Detect wireless interface (starts with wl) ---
iface=$(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | head -n 1)

# Fallback method using ip link (if iw not found)
if [ -z "$iface" ]; then
    iface=$(ip link | grep -oE 'wl[a-zA-Z0-9]+' | head -n 1)
fi

# Check if found
if [ -z "$iface" ]; then
    echo "❌ No wireless interface found!"
    exit 1
fi

echo "🔍 Wireless interface detected: $iface"

# --- Bring interface down ---
echo "⬇️ Bringing down $iface..."
sudo ifconfig "$iface" down

# --- Randomize MAC address ---
echo "🔄 Randomizing MAC address..."
sudo macchanger -r "$iface"

# --- Bring interface up ---
echo "⬆️ Bringing up $iface..."
sudo ifconfig "$iface" up

# --- Restart NetworkManager ---
echo "♻️ Restarting NetworkManager..."
sudo systemctl restart NetworkManager

echo "✅ MAC address randomized for wireless interface: $iface"
