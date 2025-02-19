#!/bin/bash

# Parse command line arguments
if [ $# -eq 1 ]; then
  # If only one argument is provided, use it as the input directory
  input_dir="$1"
else
  # Check for -i flag usage
  while getopts "i:" opt; do
    case ${opt} in
    i) input_dir="$OPTARG" ;;
    *)
      echo "Usage: $0 /path/to/directory"
      echo "   or: $0 -i /path/to/directory"
      exit 1
      ;;
    esac
  done
fi

# Check if ffsubsync is installed
if ! command -v ffsubsync &>/dev/null; then
  echo "Error: ffsubsync is not installed. Please install it with:"
  echo "pip install ffsubsync"
  exit 1
fi

# Check if the input directory exists
if [ ! -d "$input_dir" ]; then
  echo "Error: Directory '$input_dir' does not exist."
  exit 1
fi

# Get the canonical path of the input directory
input_dir=$(readlink -f "$input_dir")

# Loop over all video files in the directory
for video in "$input_dir"/*; do
  # Check if it's a file and has a video extension
  if [[ -f "$video" && "$video" =~ \.(mp4|mkv|avi|mov|flv|webm)$ ]]; then
    # Get the base filename (without the extension)
    base_filename=$(basename "$video")
    video_name="${base_filename%.*}"

    # Check if corresponding subtitle file exists
    subtitle_file="$input_dir/$video_name.srt"
    if [ ! -f "$subtitle_file" ]; then
      echo "Skipping: No subtitle file found for $video"
      continue
    fi

    echo "Processing: $video"
    echo "Aligning subtitles: $subtitle_file"

    # Create a temporary file with .srt extension
    temp_subtitle="${subtitle_file}.aligned.srt"

    # Align subtitles using ffsubsync
    if ffsubsync "$video" -i "$subtitle_file" -o "$temp_subtitle"; then
      mv "$temp_subtitle" "$subtitle_file"
      echo "Successfully aligned subtitles for: $video"
    else
      rm -f "$temp_subtitle"
      echo "Error aligning subtitles for: $video"
    fi
  fi
done
