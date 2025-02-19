#!/bin/bash

# Check if the input folder is provided
if [ -z "$1" ]; then
  echo "Usage: $0 -i /path/to/directory"
  exit 1
fi

# Parse command line arguments
while getopts "i:" opt; do
  case ${opt} in
  i) input_dir="$OPTARG" ;;
  *)
    echo "Usage: $0 -i /path/to/directory"
    exit 1
    ;;
  esac
done

# Check if the input directory exists
if [ ! -d "$input_dir" ]; then
  echo "Error: Directory '$input_dir' does not exist."
  exit 1
fi

# Loop over all video files in the directory
for video in "$input_dir"/*; do
  # Check if it's a file and has a video extension
  if [[ -f "$video" && "$video" =~ \.(mp4|mkv|avi|mov|flv|webm)$ ]]; then
    # Get the base filename (without the extension)
    base_filename=$(basename "$video")
    temp_file="${input_dir}/${base_filename%.*}_temp.${base_filename##*.}"

    echo "Checking: $video"

    # Extract the codec name using ffprobe
    codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$video")

    # Skip conversion if the video is already H.264
    if [[ "$codec" == "h264" ]]; then
      echo "Skipping: $video (Already in H.264 format)"
      continue
    fi

    echo "Processing: $video"

    # Convert the video to H.264 (NVIDIA NVENC)
    ffmpeg -i "$video" -c:v h264_nvenc -preset slow -rc vbr -cq 16 -pix_fmt yuv420p -c:a copy -c:s copy "$temp_file"

    if [ $? -eq 0 ]; then
      mv "$temp_file" "$video"
      echo "Successfully converted: $video"
    else
      echo "Error during conversion: $video"
      rm "$temp_file"
    fi
  fi
done
