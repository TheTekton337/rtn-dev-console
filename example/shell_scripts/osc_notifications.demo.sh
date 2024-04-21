#!/bin/bash

# Function to send OSC notification with a message
send_notification() {
    local message=$1
    echo "$message This will send a notification."
    echo -e "\033]337;notification|$message\007"
    # Simulate some work
    sleep $2
}

# Starting the process and sending notifications
send_notification "Starting process..." 4

send_notification "Process completed successfully." 4

send_notification "Starting another process..." 4

send_notification "Process failed. Check logs." 4