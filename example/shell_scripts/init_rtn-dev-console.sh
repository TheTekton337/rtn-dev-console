if [ -z "$STY" ] && [ -n "$SSH_TTY" ]; then
  # Default session name
  SESSION_NAME="user_session"

  # Check if LC_RTN_DEV_CONSOLE is set and adjust the session name accordingly
  if [ -n "$LC_RTN_DEV_CONSOLE" ]; then
    SESSION_NAME="comm_session"
    echo "LC_RTN_DEV_CONSOLE is set. Using communication channel session."
  else
    echo "Using default user session."
  fi

  # List Screen sessions and grep for our session name
  screen -list | grep -q "$SESSION_NAME"

  # Check if the session exists (grep exits with 0 if it finds the name)
  if [ $? -eq 0 ]; then
    echo "Resuming Screen session: $SESSION_NAME"
    exec screen -r $SESSION_NAME
  else
    echo "Starting a new Screen session: $SESSION_NAME"
    exec screen -S $SESSION_NAME
  fi
fi
