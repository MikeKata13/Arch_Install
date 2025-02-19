#!/bin/bash
# Upload newer versions from local to Google Drive
rclone sync ~/Drive "Google Drive":/ --update -P --delete-during --track-renames

# Download newer versions from Google Drive to local
rclone sync "Google Drive":/ ~/Drive --update -P --delete-during --drive-skip-gdocs
