#!/bin/bash

# RAM and disk monitoring script with Telegram notifications
# Load configuration file

CONFIG_FILE="config.env"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found!"
    exit 1
fi

source "$CONFIG_FILE"

# Function to send messages via Telegram
send_telegram_message() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d text="$message" \
        -d parse_mode="HTML" > /dev/null
}

# Check RAM usage
ram_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
if [ "$ram_usage" -gt "$RAM_THRESHOLD" ]; then
    message="⚠️ <b>RAM Alert</b>%0A"
    message+="Current usage: ${ram_usage}%%0A"
    message+="Configured threshold: ${RAM_THRESHOLD}%"
    send_telegram_message "$message"
    echo "RAM alert sent: ${ram_usage}%"
fi

# Check disk usage
df -h | grep -vE '^Filesystem|tmpfs|cdrom|loop' | awk '{print $5 " " $1 " " $6}' | while read output; do
    usage=$(echo "$output" | awk '{print $1}' | sed 's/%//')
    partition=$(echo "$output" | awk '{print $2}')
    mount_point=$(echo "$output" | awk '{print $3}')
    
    # Skip if usage is not a number - may cause problems in italian language version otherwise
    if ! [[ "$usage" =~ ^[0-9]+$ ]]; then
        continue
    fi
    
    if [ "$usage" -gt "$DISK_THRESHOLD" ]; then
        message="⚠️ <b>Disk Alert</b>%0A"
        message+="Partition: ${partition}%0A"
        message+="Mount point: ${mount_point}%0A"
        message+="Current usage: ${usage}%%0A"
        message+="Configured threshold: ${DISK_THRESHOLD}%"
        send_telegram_message "$message"
        echo "Disk alert sent for ${partition}: ${usage}%"
    fi
done

echo "Check completed at $(date)"