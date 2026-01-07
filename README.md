# System Monitor Telegram Bot

A minimal Bash script designed for Linux servers to monitor system resources and send real-time alerts via Telegram.

## Features
- **RAM Monitoring**: Alerts when RAM usage exceeds a configurable threshold.
- **Disk Usage**: Monitors all mounted partitions and alerts if they exceed a specific percentage.
- **Telegram Integration**: Uses Telegram Bot API for instant notifications.
- **Decoupled Config**: Environment variables are managed in a separate file for security.

## Prerequisites
- A Linux environment (or Git Bash for testing).
- `curl` installed (`sudo apt install curl` on Ubuntu/Debian).
- A Telegram Bot (created via @BotFather).

## Setup
1. Clone the repo: `git clone https://github.com/your-user/system-monitor-telegram-bot.git`
2. Create your config file: `cp config.env.example config.env`
3. Edit `config.env` with your Bot Token and Chat ID.
4. Give execution permissions: `chmod +x monitor.sh`
5. Run it: `./monitor.sh`

## Automation
To run this check every hour, add this to your crontab (`crontab -e`):
`0 * * * * /path/to/monitor.sh`
