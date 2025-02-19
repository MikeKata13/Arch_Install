#!/bin/bash

# Get the target directory from the command line
TARGET_DIR=$1

# Use GPU flag
USE_GPU=${2:-false}

# Check if the target directory is provided and exists
if [ $# -lt 1 ] || [ ! -d "$TARGET_DIR" ]; then
  echo "Usage: $0 /path/to/target/directory [use_gpu]"
  exit 1
fi

echo "Processing files in: $TARGET_DIR"
echo "Using GPU: $USE_GPU"

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

  # Generate the output file name with the same extension and temporary suffix
  OUTPUT="${VIDEO%.*}.tmp.${EXTENSION}"

  # Set the correct output format based on the extension
  case "$EXTENSION" in
  mkv)
    FORMAT="matroska"
    ;;
  mp4)
    FORMAT="mp4"
    ;;
  avi)
    FORMAT="avi"
    ;;
  mov)
    FORMAT="mov"
    ;;
  wmv)
    FORMAT="asf"
    ;;
  *)
    echo "Unsupported format: $EXTENSION"
    continue
    ;;
  esac

  # Run ffmpeg to convert the video to h264 using GPU or CPU
  echo -e "====================\nProcessing $VIDEO..."

  if [ "$USE_GPU" = true ]; then
    ffmpeg -i "$VIDEO" -c:v h264_nvenc -rc vbr -cq 20 -preset fast -c:a copy -map_metadata 0 -f "$FORMAT" "$OUTPUT"
  else
    ffmpeg -i "$VIDEO" -c:v libx264 -crf 23 -preset veryfast -c:a copy -threads 0 -map_metadata 0 -f "$FORMAT" "$OUTPUT"
  fi

  if [ $? -eq 0 ]; then
    mv "$OUTPUT" "${VIDEO%.*}.${EXTENSION}"
    echo " Success"
    PROCESSED_FILES=$((PROCESSED_FILES + 1))
  else
    rm "$OUTPUT"
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
