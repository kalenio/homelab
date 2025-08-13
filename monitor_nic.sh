#!/bin/bash

# Create: nano /usr/local/bin/monitor_nic_fail.sh
# Make executable: chmod +x /usr/local/bin/monitor_nic_fail.sh
# Run for the first time (in background): /usr/local/bin/monitor_nic_fail.sh &
# Add this line to crontab (crontab -e) to run on reboot: @reboot /usr/local/bin/monitor_nic_fail.sh

# NIC to monitor
NIC="eno2"
HANG_MSG="Detected Hardware Unit Hang"

# Log files
RESET_LOG="/var/log/nic_reset.log"
DEBUG_LOG="/var/log/nic_monitor_debug.log"

# Debounce settings
DEBOUNCE_SECONDS=60
LAST_RESET=0

echo "$(date): NIC monitor script starting for $NIC" >> "$DEBUG_LOG"

# Follow the kernel logs in real-time
journalctl -fu kernel |
while read -r line; do
    # Log everything it sees for debugging
    echo "$(date): $line" >> "$DEBUG_LOG"

    # If the line contains the hang message
    if [[ "$line" == *"$HANG_MSG"* ]]; then
        CURRENT_TIME=$(date +%s)
        TIME_SINCE_RESET=$((CURRENT_TIME - LAST_RESET))

        if (( TIME_SINCE_RESET >= DEBOUNCE_SECONDS )); then
            echo "$(date): Hardware unit hang detected on $NIC. Resetting NIC..." | tee -a "$RESET_LOG" "$DEBUG_LOG"

            # Reset NIC
            ip link set "$NIC" down
            ip link set "$NIC" up

            # Restart networking service
            systemctl restart networking.service

            echo "$(date): Reset complete." >> "$DEBUG_LOG"

            LAST_RESET=$CURRENT_TIME
        else
            echo "$(date): Hang detected but skipped reset (last reset $TIME_SINCE_RESET seconds ago)" >> "$DEBUG_LOG"
        fi
    fi
done
