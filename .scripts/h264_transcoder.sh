#!/bin/bash

recursive=false # Default: do not process subdirectories

# Usage message
usage() {
  echo "Usage: $0 -i /path/to/directory [-r]"
  echo "  -i   Specify input directory"
  echo "  -r   Enable recursive processing (optional)"
  exit 1
}

# Parse command line arguments
while getopts "i:r" opt; do
  case ${opt} in
  i) input_dir="$OPTARG" ;;
  r) recursive=true ;;
  *) usage ;;
  esac
done

# Check if input directory is provided
if [ -z "$input_dir" ]; then
  usage
fi

# Check if the input directory exists
if [ ! -d "$input_dir" ]; then
  echo "Error: Directory '$input_dir' does not exist."
  exit 1
fi

# Find all video files (with or without recursion)
if $recursive; then
  find "$input_dir" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.flv" -o -iname "*.webm" \) -print0 |
  while IFS= read -r -d '' video; do
else
  find "$input_dir" -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.flv" -o -iname "*.webm" \) -print0 |
  while IFS= read -r -d '' video; do
fi

  # Get the base filename (without extension)
  base_filename=$(basename "$video")
  output_file="${video%.*}_h264_nvenc.${base_filename##*.}"

  echo "Checking: $video"

  # Extract the codec name using ffprobe
  codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$video")

  # Skip conversion if already in H.264
  if [[ "$codec" == "h264" ]]; then
    echo "Skipping: $video (Already in H.264 format)"
    continue
  fi

  echo "Processing: $video"

  # Convert the video to H.264 (NVIDIA NVENC)
  ffmpeg -i "$video" -c:v h264_nvenc -preset slow -rc vbr -cq 19 -pix_fmt yuv420p -c:a copy -c:s copy -c:t copy "$output_file"

  if [ $? -eq 0 ]; then
    echo "Successfully converted: $video -> $output_file"
  else
    echo "Error during conversion: $video"
  fi
done <<<"$file_list"
