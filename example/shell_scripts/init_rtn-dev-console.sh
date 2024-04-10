#!/bin/bash

# Define session names
USER_SESSION_NAME="user_session"
COMM_SESSION_NAME="comm_session"

# Ensure the comm session is always running
screen -list | grep -q "$COMM_SESSION_NAME"
if [ $? -ne 0 ]; then
  echo "Starting background communication session: $COMM_SESSION_NAME"
  screen -dmS "$COMM_SESSION_NAME"
fi

# Determine which session to attach to
if [ -n "$LC_RTN_DEV_CONSOLE" ]; then
  # For the React Native app, we might just ensure the comm session exists but not attach to it
  echo "Communication session is ready."
else
  # For regular users, attach to or create the user session
  if [ -z "$STY" ] && [ -n "$SSH_TTY" ]; then
    screen -list | grep -q "$USER_SESSION_NAME"
    if [ $? -eq 0 ]; then
      echo "Resuming Screen session: $USER_SESSION_NAME"
      exec screen -r "$USER_SESSION_NAME"
    else
      echo "Starting a new Screen session: $USER_SESSION_NAME"
      exec screen -S "$USER_SESSION_NAME"
    fi
  fi
fi
