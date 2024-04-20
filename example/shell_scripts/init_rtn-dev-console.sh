#!/bin/bash

# TODO: Refactor to support setting up screens on login based on configs from RTN.
# TODO: Create RFC for standardizing this within pntkl project.

# Check if the environment variable LC_RTN_DEV_CONSOLE is set
if [ -n "$LC_RTN_DEV_CONSOLE" ]; then
    # Define session names
    USER_SESSION_NAME="user_session"
    COMM_SESSION_NAME="comm_session"

    # Function to check if a screen session exists
    session_exists() {
        screen -list | grep -q "\.$1[[:space:]]"
    }

    # Ensure the comm session is always running
    session_exists "$COMM_SESSION_NAME"
    if [ $? -ne 0 ]; then
      echo "Starting background communication session: $COMM_SESSION_NAME"
      screen -dmS "$COMM_SESSION_NAME"
    fi

    # Ensure user session exists but do not attach to it automatically
    session_exists "$USER_SESSION_NAME"
    if [ $? -ne 0 ]; then
        echo "Starting a new Screen session for user: $USER_SESSION_NAME"
        screen -dmS "$USER_SESSION_NAME"
    else
        echo "User session $USER_SESSION_NAME already exists."
    fi

    # Additional logic to attach to the user session or perform other actions
    # can be placed here if needed. For example, attaching to the user session:
    echo "Resuming Screen session: $USER_SESSION_NAME"
    exec screen -r "$USER_SESSION_NAME"
else
    echo "LC_RTN_DEV_CONSOLE not set. No screen sessions will be started."
fi
