#!/bin/bash

# Set the directory path
directory="prisoners"

# Check if the directory exists
if [ -d "$directory" ]; then
  echo -n > answer.log
  
  # List all subfolders inside the directory
  subfolders=$(find "$directory" -mindepth 1 -maxdepth 1 -type d)

  # Loop through each subfolder, prisoner and logs its answer
  for folder in $subfolders; do
    folder_name=$(basename "$folder")  # Extract the folder name
    echo "Executing command inside $folder_name"
    
    # Change to the subfolder directory
    cd "$folder"
    
    # Execute prisoner's code
    answer=$(cargo run 2 "$folder_name" "$folder_name" cake)

    # Change back to the original directory
    cd - > /dev/null 2>&1

    echo "$folder_name $answer" >> answer.log
  done
else
  echo "Directory '$directory' does not exist."
fi
