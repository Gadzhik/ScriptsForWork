#!/usr/bin/env bash

# Check ffmpeg
if ! command -v ffmpeg &> /dev/null; then
  echo "FFmpeg not install. Installing..."
  sudo apt-get update
  sudo apt-get install -y ffmpeg
  if [ $? -ne 0 ]; then
    echo "Error installing FFmpeg. Please, install manually."
    exit 1
  fi
fi

# Path to video file
VIDEO_FILE="la.ts"

# Checking the existence of a video file
if [ ! -f "$VIDEO_FILE" ]; then
  echo "Video file '$VIDEO_FILE' not found."
  exit 1
fi

# Creating playlist.txt
echo "Creating playlist.txt"
touch playlist.txt
for i in $(seq 1 1 100); do
  echo "file '$VIDEO_FILE'" >> playlist.txt
done

# Starting streaming with ffmpeg
echo "Starting streaming with..."
ffmpeg -re -f concat -i playlist.txt -c copy -f mpegts udp://224.0.0.111:5005

exit 0