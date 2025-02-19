#!/bin/bash

# Get the target directory from the command line
TARGET_DIR=$1

# Check if the target directory is provided and exists
if [ $# -ne 1 ] || [ ! -d "$TARGET_DIR" ]; then
  echo "Usage: $0 /path/to/target/directory"
  exit 1
fi

echo "Processing files in: $TARGET_DIR"

# Change to the target directory
cd "$TARGET_DIR" || {
  echo "Failed to change to directory: $TARGET_DIR"
  exit 1
}

# Find all video files
VIDEO_FILES=$(find . -type f -iregex '.*\.\(mkv\|mp4\|avi\|mov\|wmv\)$')

# Initialize counters
TOTAL_FILES=0
PROCESSED_FILES=0

# Calculate total files at the start
TOTAL_FILES=$(echo "$VIDEO_FILES" | wc -l)

# Function to display progress percentage
progress_percentage() {
  local progress=$(($1 * 100 / $TOTAL_FILES))
  echo -e "\nProgress: ${progress}%\n"
}

# Process each video file
for VIDEO in $VIDEO_FILES; do
  # Get the file extension
  EXTENSION="${VIDEO##*.}"

  # Generate the output file name with .mp4 extension
  OUTPUT="${VIDEO%.*}.mp4"

  # Run ffmpeg to convert the video to h264
  echo -e "====================\nProcessing $VIDEO..."
  ffmpeg -i "$VIDEO" -c:v libx264 -crf 23 -preset veryfast -c:a aac -b:a 128k "$OUTPUT"

  if [ $? -eq 0 ]; then
    echo " Success"
    PROCESSED_FILES=$((PROCESSED_FILES + 1))
  else
    echo " Failure"
  fi

  # Update progress percentage
  progress_percentage $PROCESSED_FILES
done

# Change back to the original directory
cd "$(pwd -P)" || {
  echo "Failed to return to original directory"
  exit 1
}

echo -e "\nDone. Processed $PROCESSED_FILES out of $TOTAL_FILES files."
