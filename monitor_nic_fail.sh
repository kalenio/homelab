#!/bin/bash

# Define the NIC name and the log to monitor
NIC="eno2"
LOG_FILE="/var/log/syslog"  # Or /var/log/messages depending on your distribution
HANG_MSG="Detected Hardware Unit Hang"

# Loop to continuously check the logs
while true; do
    # Check if the "Detected Hardware Unit Hang" message is in the syslog
    if grep -q "$HANG_MSG" "$LOG_FILE"; then
        echo "Hardware unit hang detected on $NIC. Resetting NIC..."
        
        # Reset the NIC interface
        ip link set $NIC down
        ip link set $NIC up
        
        # Restart the network service or the whole network interface
        systemctl restart networking.service
        
        # Log the reset
        echo "$(date): $NIC reset due to hardware hang" >> /var/log/nic_reset.log
    fi
    
    # Sleep for a bit before checking again
    sleep 10
done
