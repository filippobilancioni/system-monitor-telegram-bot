#!/bin/bash

# Load configuration variables from the .env file
if [ -f config.env ]; then
    # Export variables while ignoring comments and empty lines
    export $(grep -v '^#' config.env | xargs)
else
    echo "Error: config.env file not found!"
    exit 1
fi

HOSTNAME=$(hostname)

# Function to send messages via Telegram Bot API
send_telegram() {
    local message=$1
    # Use curl to trigger the sendMessage endpoint
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
         -d chat_id="$CHAT_ID" \
         -d text="$message" > /dev/null
}

echo "--- Starting System Check on $HOSTNAME ---"

# 1. RAM MONITORING
# Extract free memory percentage using 'free' and 'awk'
FREE_RAM_PCT=$(free | grep Mem | awk '{print $4/$2 * 100.0}')
# Truncate decimal part using Shell Parameter Expansion for integer comparison
FREE_RAM_PCT=${FREE_RAM_PCT%.*}

echo "Current Free RAM: $FREE_RAM_PCT%"

if [ "$FREE_RAM_PCT" -lt "$RAM_THRESHOLD" ]; then
    MSG="⚠️ RAM ALERT ($HOSTNAME): Only $FREE_RAM_PCT% of memory is free!"
    echo "$MSG"
    send_telegram "$MSG"
fi

# 2. DISK USAGE MONITORING
# Iterate through all mounted partitions starting with /dev/
df -h | grep '^/dev/' | while read -r line; do
    # Extract usage percentage (5th column) and remove the '%' symbol
    USAGE=$(echo "$line" | awk '{print $5}' | sed 's/%//g')
    # Extract partition name (1st column)
    PARTITION=$(echo "$line" | awk '{print $1}')
    
    echo "Checking $PARTITION: $USAGE% used"

    if [ "$USAGE" -gt "$DISK_THRESHOLD" ]; then
        MSG="🚨 DISK ALERT ($HOSTNAME): Partition $PARTITION is $USAGE% full!"
        echo "$MSG"
        send_telegram "$MSG"
    fi
done

echo "--- Check Completed ---"