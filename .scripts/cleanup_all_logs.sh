#!/bin/bash

# Path to the logs folder
LOGS_FOLDER="$HOME/.local/logs"

# Log file for cleanup script
CLEANUP_LOGFILE="$HOME/.local/logs/cleanup.log"

# Start logging
echo "Cleanup script started at $(date)" >>"$CLEANUP_LOGFILE"

# Delete all log files older than 3 weeks (21 days)
find "$LOGS_FOLDER" -type f -name "*.log" -exec rm {} \; >>"$CLEANUP_LOGFILE" 2>&1

# Log the completion of file deletion
echo "Deletion of old log files completed at $(date)" >>"$CLEANUP_LOGFILE"

# Optionally, create a new empty log file
#touch "$LOGS_FOLDER/sync_disks.log"
#echo "New log file created at $(date)" >>"$CLEANUP_LOGFILE"

# Finish logging
echo "Cleanup script finished at $(date)" >>"$CLEANUP_LOGFILE"
