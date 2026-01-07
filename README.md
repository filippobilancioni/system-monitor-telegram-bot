# System Resource Monitor (Dockerized)

A minimal Bash-based monitoring solution designed to run as a lightweight Docker container. It monitors host system resources (RAM and Disk) and sends instant alerts via Telegram.

## Features
- **Docker Ready**: Fully containerized using Alpine Linux (minimal footprint).
- **Continuous Monitoring**: Runs as a background process with a configurable sleep interval.
- **Host Monitoring**: Uses read-only bind mounts to monitor the actual host machine from inside the container.
- **Smart Alerts**: Filters virtual filesystems to avoid duplicate notifications.
- **Secure**: Sensitive data (Tokens) are decoupled from the logic using environment variables.

## Prerequisites
- Docker and Docker Compose installed.
- A Telegram Bot (created via `@BotFather`).

## Setup & Installation

1. Clone the repo:
   ```bash
   git clone [https://github.com/filippobilancioni/system-monitor-telegram-bot.git](https://github.com/your-user/system-monitor-telegram-bot.git)
   cd system-monitor-telegram-bot
2. Configure Variables: Create a .env file in the root directory (this file is git-ignored):
   ```bash
   TELEGRAM_BOT_TOKEN=your_bot_token_here
   TELEGRAM_CHAT_ID=your_chat_id_here
3. Configure Thresholds: Open docker-compose.yml to adjust your monitoring limits and frequency:
   <pre>
   environment:
   - RAM_THRESHOLD=75      # Alert if RAM &gt; 80%
   - DISK_THRESHOLD=80     # Alert if Disk &gt; 85%
   - SLEEP_INTERVAL=3600   # Check every hour (in seconds)
   </pre>
4. Run the Monitor:
   ```bash
   docker-compose up -d --build

## Monitoring & Logs
- To check the status of your monitor and verify that it is running correctly:
  ```bash
  docker logs -f system-telegram-monitor
