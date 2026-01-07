FROM alpine:latest

# Install bash, curl and cron daemon
RUN apk add --no-cache bash curl

WORKDIR /app

# Copy the files (config.env.example needed if variables are not given)
COPY monitor.sh .
COPY config.env ./config.env
RUN chmod +x monitor.sh

# Timer
CMD ["/bin/bash", "/app/monitor.sh"]
