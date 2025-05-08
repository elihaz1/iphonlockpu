#!/bin/bash

# Set the exact name of your iPhone as it appears in Bluetooth
IPHONE_NAME="Your iPhone Name Here"  # Replace with the exact Bluetooth name of your iPhone

# RSSI threshold: if the RSSI drops below this value, the screen will lock
RSSI_THRESHOLD=-65
CONSECUTIVE_THRESHOLD=3
LOW_RSSI_COUNT=0

# Log file location
LOG_FILE="/tmp/iphone-lock-monitor.log"

# To view the log in real-time, run in Terminal:
# tail -f /tmp/iphone-lock-monitor.log

# Function to retrieve the RSSI value of the iPhone via system_profiler
get_rssi() {
    /usr/sbin/system_profiler SPBluetoothDataType | /usr/bin/awk -v name="$IPHONE_NAME" '
        BEGIN { rssi = "" }
        $0 ~ name { found = 1 }
        found && /RSSI:/ {
            rssi = $2
            exit
        }
        END { print rssi }'
}

# Initial sleep interval
SLEEP_INTERVAL=10
RSSI_HISTORY=()
MAX_HISTORY=3

# Infinite loop: adaptive polling based on RSSI trend
while true; do
    RSSI=$(get_rssi)
    TIMESTAMP=$(/bin/date)

    if [ -z "$RSSI" ]; then
        echo "$TIMESTAMP - RSSI not found. iPhone may be out of range or not connected." | /usr/bin/tee -a "$LOG_FILE"
        LOW_RSSI_COUNT=0
    else
        echo "$TIMESTAMP - iPhone RSSI: $RSSI" | /usr/bin/tee -a "$LOG_FILE"

        # Update RSSI history before threshold check
        RSSI_HISTORY=("${RSSI_HISTORY[@]}" "$RSSI")
        if [ ${#RSSI_HISTORY[@]} -gt $MAX_HISTORY ]; then
            RSSI_HISTORY=("${RSSI_HISTORY[@]:1}")
        fi

        # Check for downward trend
        if [ ${#RSSI_HISTORY[@]} -eq $MAX_HISTORY ]; then
            if [[ "${RSSI_HISTORY[0]}" -gt "${RSSI_HISTORY[1]}" && "${RSSI_HISTORY[1]}" -gt "${RSSI_HISTORY[2]}" ]]; then
                SLEEP_INTERVAL=1
                echo "$TIMESTAMP - RSSI dropping. Increasing polling rate to 1s." | /usr/bin/tee -a "$LOG_FILE"
            else
                SLEEP_INTERVAL=10
            fi
        fi

        # Threshold logic with 3 consecutive low readings
        if [ "$RSSI" -lt "$RSSI_THRESHOLD" ]; then
            LOW_RSSI_COUNT=$((LOW_RSSI_COUNT + 1))
            echo "$TIMESTAMP - RSSI below threshold ($LOW_RSSI_COUNT consecutive)" | /usr/bin/tee -a "$LOG_FILE"
        else
            LOW_RSSI_COUNT=0
        fi

        if [ "$LOW_RSSI_COUNT" -ge "$CONSECUTIVE_THRESHOLD" ]; then
            echo "$TIMESTAMP - RSSI too low for $CONSECUTIVE_THRESHOLD consecutive checks. Locking screen..." | /usr/bin/tee -a "$LOG_FILE"
            /usr/bin/pmset displaysleepnow
            LOW_RSSI_COUNT=0
        fi
    fi

    /bin/sleep $SLEEP_INTERVAL
done
