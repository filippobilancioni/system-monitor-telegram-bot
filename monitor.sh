#!/bin/bash

# =================================================================
# System Resource Monitor with Telegram Notifications
# Optimized for Docker (Infinite loop + Environment Variables)
# =================================================================

# Load local configuration file if it exists
CONFIG_FILE="config.env"
if [ -f "$CONFIG_FILE" ]; then
    # Use source while cleaning Windows-style \r line endings
    # This prevents "command not found" errors on files created in Windows
    export $(grep -v '^#' "$CONFIG_FILE" | sed 's/\r$//' | xargs)
fi

# Set variables (Prioritize Docker Environment, fall back to defaults)
TOKEN="${TELEGRAM_BOT_TOKEN}"
ID="${TELEGRAM_CHAT_ID}"
RAM_LIMIT="${RAM_THRESHOLD:-80}"
DISK_LIMIT="${DISK_THRESHOLD:-80}"
WAIT_TIME="${SLEEP_INTERVAL:-3600}"

# Function to send messages via Telegram API
send_telegram() {
    local text="$1"
    curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        -d chat_id="${ID}" \
        -d text="$text" \
        -d parse_mode="HTML" > /dev/null
}

echo "--- Monitoring started at $(date) ---"
echo "RAM Threshold: $RAM_LIMIT% | Disk Threshold: $DISK_LIMIT% | Interval: ${WAIT_TIME}s"

# INFINITE LOOP
while true; do
    echo "[$(date)] Running health check..."

    # 1. RAM CHECK
    # Calculate percentage of used memory using 'free'
    ram_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    
    if [ "$ram_usage" -gt "$RAM_LIMIT" ]; then
        msg="⚠️ <b>RAM Alert</b>%0ACurrent usage: ${ram_usage}% (Threshold: ${RAM_LIMIT}%)"
        send_telegram "$msg"
        echo "RAM alert sent: ${ram_usage}%"
    fi

    # 2. DISK CHECK
    # Check if host root is mapped (Docker environment), otherwise use default root
    CHECK_PATH="/"
    if [ -d "/host_root" ]; then CHECK_PATH="/host_root"; fi

    # Target the main mount point to avoid duplicates from virtual filesystems
    # 2>/dev/null suppresses permission errors on protected system folders
    disk_data=$(df -h "$CHECK_PATH" 2>/dev/null | tail -1)
    disk_usage=$(echo "$disk_data" | awk '{print $5}' | sed 's/%//')
    partition=$(echo "$disk_data" | awk '{print $1}')

    # Validate numeric value and compare against threshold
    if [[ "$disk_usage" =~ ^[0-9]+$ ]] && [ "$disk_usage" -gt "$DISK_LIMIT" ]; then
        msg="⚠️ <b>Disk Alert</b>%0APartition: ${partition}%0AUsage: ${disk_usage}% (Threshold: ${DISK_LIMIT}%)"
        send_telegram "$msg"
        echo "Disk alert sent: ${disk_usage}% on partition ${partition}"
    fi

    echo "Check completed. Next check in ${WAIT_TIME}s."
    
    # Wait for the specified interval before the next iteration
    sleep "$WAIT_TIME"
done