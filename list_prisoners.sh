#!/bin/bash

# Set the directory path
directory="prisoners"

# Check if the directory exists
if [ -d "$directory" ]; then
  # List all subfolders inside the directory
  subfolders=$(find "$directory" -mindepth 1 -maxdepth 1 -type d)
  
  # Loop through each subfolder and print its name
  for folder in $subfolders; do
    folder_name=$(basename "$folder")  # Extract the folder name
    echo "$folder_name"
  done
else
  echo "Directory '$directory' does not exist."
fi
