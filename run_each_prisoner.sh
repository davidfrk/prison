#!/bin/bash

# Cd to bot's folder and call ./run.sh with correct parameters
call_bot(){
  folder=$1
  first_prisoner=$2
  second_prisoner=$3
  cake=$4

  cd "$folder"

  # Generating parameters
  parameters="$first_prisoner $second_prisoner"

  if [[ $cake == true ]]; then
    parameters+=" cake"
  fi

  answer=$(./run.sh $parameters)
  cd - > /dev/null 2>&1

  echo $parameters >> calls.log
  echo $answer
}

# Set the directory path
directory="prisoners"

# Check if the directory exists
if [ -d "$directory" ]; then
  echo -n > answers.log
  echo -n > calls.log
  
  # List all subfolders inside the directory
  subfolders=$(find "$directory" -mindepth 1 -maxdepth 1 -type d)
  cake=true

  # Loop through each subfolder, prisoner and logs its answer
  for folder in $subfolders; do
    prisoner_name=$(basename "$folder")  # Extract the folder name
    echo "Executing command inside $prisoner_name"
    
    # Execute prisoner's code
    answer=$(call_bot $folder $prisoner_name $prisoner_name $cake)

    echo "$prisoner_name $answer"
    echo "$prisoner_name $answer" >> answers.log
  done
else
  echo "Directory '$directory' does not exist."
fi
