#!/bin/bash

# Directories to sync
SRC_DIR1="/mnt/shared1/Multimedia"
DST_DIR1="/mnt/shared2/Multimedia"
SRC_DIR2="/mnt/shared1/OneDrive"
DST_DIR2="/mnt/shared2/OneDrive"

# Log file
LOGFILE="$HOME/.local/logs/sync_disks.log"

# Sync Multimedia directories
rsync -av "$SRC_DIR1/" "$DST_DIR1/" >>"$LOGFILE" 2>&1
rsync -av "$DST_DIR1/" "$SRC_DIR1/" >>"$LOGFILE" 2>&1

# Sync OneDrive directories
rsync -av "$SRC_DIR2/" "$DST_DIR2/" >>"$LOGFILE" 2>&1
rsync -av "$DST_DIR2/" "$SRC_DIR2/" >>"$LOGFILE" 2>&1

# Add a timestamp to the log
echo "Sync completed at $(date)" >>"$LOGFILE"
