#!/bin/bash
# Directories to sync
SRC_DIR1="/mnt/shared2/Multimedia"
DST_DIR1="/mnt/shared1/Multimedia"
SRC_DIR2="/mnt/shared2/OneDrive"
DST_DIR2="/mnt/shared1/OneDrive"

# Log file
LOGFILE="$HOME/.local/logs/sync_media.log"

# Function to sync directories
sync_dirs() {
  # Sync Multimedia directories
  rsync -av "$SRC_DIR1/" "$DST_DIR1/" >>"$LOGFILE" 2>&1

  # Sync OneDrive directories
  rsync -av "$SRC_DIR2/" "$DST_DIR2/" >>"$LOGFILE" 2>&1
}

# Initial sync
sync_dirs

# Watch for changes and sync
while inotifywait -r -e modify,create,delete,move "$SRC_DIR1" "$SRC_DIR2"; do
  sync_dirs
done
