#!/bin/bash

# Display the answer counts for each prisoner
print_prisoner_data(){
  # Display the answer counts for each prisoner
  echo "Prisoner answer counts:"
  for prisoner in "${!prisoner_data[@]}"; do
    current_count=${prisoner_data["$prisoner"]}
    echo "$prisoner:$current_count"
  done
}

log_table_data(){
  logfile="prison.log"

  line="Name"
  name_column_length=28

  while [ ${#line} -lt $name_column_length ]; do
    line+=$' '
  done

  line+="Score\tCooperated\tDefected\tBoth_Cooperated\tBoth_Defected\tWas_Betrayed\tDid_Betray"
  echo -e "$line" > "$logfile"

  #Lets create a sorted list of prisoners ordered by their score
  sorted_prisoners=($(for prisoner in "${prisoners[@]}";
   do echo "$prisoner $(get_data_or_zero $prisoner score)"; done | sort -k2nr | cut -d' ' -f1))

  # Log lines using sorted_prisoners
  for prisoner in "${sorted_prisoners[@]}"; do
    log_line $prisoner $logfile
  done
}

log_line(){
  prisoner_name=$1
  logfile=$2

  score=$(get_data_or_zero $prisoner_name score)
  cooperated=$(get_data_or_zero $prisoner_name Cooperate)
  defected=$(get_data_or_zero $prisoner_name Defect)
  both_cooperated=$(get_data_or_zero $prisoner_name BothCooperated)
  both_defected=$(get_data_or_zero $prisoner_name BothDefected)
  was_betrayed=$(get_data_or_zero $prisoner_name WasBetrayed)
  did_betray=$(get_data_or_zero $prisoner_name Betrayed)

  line="$prisoner_name"
  character_counter=28

  while [ ${#line} -lt $character_counter ]; do
    line+=$' '
  done

  line="$line$score\t\t$cooperated\t\t$defected"
  line="$line\t\t$both_cooperated\t\t$both_defected\t\t$was_betrayed\t\t$did_betray"
  echo -e "$line" >> "$logfile"
}

get_data_or_zero(){
  prisoner_name=$1
  data=$2

  current=${prisoner_data["$prisoner_name:$data"]}
  if [[ -z $current ]]; then
    current=0
  fi

  echo $current
}

# Increments prisoner_name:data, used to track statistics from each prisoner
record_prisoner_data(){
  prisoner_name=$1
  data=$2

  current_count=$(get_data_or_zero $prisoner_name $data)
  ((prisoner_data["$prisoner_name:$data"]=$current_count + 1))
}

# Score prisoner, add data under prisoner_name:score
score_prisoner(){
  prisoner_name=$1
  data=$2

  current_count=$(get_data_or_zero $prisoner_name score)
  ((prisoner_data["$prisoner_name:score"]=$current_count + $data))
}

# Cd to bot's folder and call ./run.sh with correct parameters
call_bot(){
  folder=$1
  first_prisoner=$2
  second_prisoner=$3
  cake=$4

  cd "$folder"

  # Generating parameters
  parameters="$first_prisoner $second_prisoner"
  parameters+=" $(get_data_or_zero "$first_prisoner:$second_prisoner" "Defected")"
  parameters+=" $(get_data_or_zero "$second_prisoner:$first_prisoner" "Defected")"
  if [[ $cake == true ]]; then
    parameters+=" cake"
  fi

  answer=$(./run.sh $parameters 2>/dev/null)
  cd - > /dev/null 2>&1

  echo $answer
}

# Run round where all the prisoners play with one another
prisoners_dilemma_round(){
  cake=false
  if [[ -n $1 &&  "$1" == "cake" ]]; then
    cake=true
  fi
  echo "Round cake $cake."

  # Loop through each subfolder, prisoner pair and logs their answer
  for ((i=0; i<${#subfolders[@]}; i++)); do
    for ((j=i+1; j<${#subfolders[@]}; j++)); do
      folder1="${subfolders[$i]}"
      folder2="${subfolders[$j]}"

      prisoner1_name=$(basename "$folder1")
      prisoner2_name=$(basename "$folder2")

      echo "Running $prisoner1_name against $prisoner2_name."

      # Execute prisoner1's code
      answer1=$(call_bot $folder1 $prisoner1_name $prisoner2_name $cake)

      # Execute prisoner2's code
      answer2=$(call_bot $folder2 $prisoner2_name $prisoner1_name $cake)

      # Log each prisoner and their answer
      echo "$prisoner1_name $answer1 $prisoner2_name $answer2" >> answer.log

      record_prisoner_data $prisoner1_name $answer1
      record_prisoner_data $prisoner2_name $answer2

      # Score for each result
      score_both_cooperated=8
      score_both_defected=5
      score_betrayed=10
      score_was_betrayed=0

      cake_bonus=1
      if [[ cake == true ]]; then
        cake_bonus=5
      fi

      # Comparing answers
      if [ "$answer1" == "$answer2" ]; then
        if [ "$answer1" == "Cooperate" ]; then
          record_prisoner_data $prisoner1_name "BothCooperated"
          record_prisoner_data $prisoner2_name "BothCooperated"
          score_prisoner $prisoner1_name $(($score_both_cooperated * cake_bonus))
          score_prisoner $prisoner2_name $(($score_both_cooperated * cake_bonus))

          record_prisoner_data "$prisoner1_name:$prisoner2_name" "Cooperated"
          record_prisoner_data "$prisoner2_name:$prisoner1_name" "Cooperated"
        else
          record_prisoner_data $prisoner1_name "BothDefected"
          record_prisoner_data $prisoner2_name "BothDefected"
          score_prisoner $prisoner1_name $(($score_both_defected * cake_bonus))
          score_prisoner $prisoner2_name $(($score_both_defected * cake_bonus))

          record_prisoner_data "$prisoner1_name:$prisoner2_name" "Defected"
          record_prisoner_data "$prisoner2_name:$prisoner1_name" "Defected"
        fi
      else
        if [ "$answer1" == "Cooperate" ]; then
          record_prisoner_data $prisoner1_name "WasBetrayed"
          record_prisoner_data $prisoner2_name "Betrayed"
          score_prisoner $prisoner1_name $(($score_was_betrayed * cake_bonus))
          score_prisoner $prisoner2_name $(($score_betrayed * cake_bonus))

          record_prisoner_data "$prisoner1_name:$prisoner2_name" "Cooperated"
          record_prisoner_data "$prisoner2_name:$prisoner1_name" "Defected"
        else
          record_prisoner_data $prisoner1_name "Betrayed"
          record_prisoner_data $prisoner2_name "WasBetrayed"
          score_prisoner $prisoner1_name $(($score_betrayed * cake_bonus))
          score_prisoner $prisoner2_name $(($score_was_betrayed * cake_bonus))

          record_prisoner_data "$prisoner1_name:$prisoner2_name" "Defected"
          record_prisoner_data "$prisoner2_name:$prisoner1_name" "Cooperated"
        fi
      fi
    done
  done
}

# Main
# Set the directory path
directory="prisoners"

# Check if the directory exists
if [ -d "$directory" ]; then
  echo -n > answer.log

  # List all subfolders inside the directory
  subfolders=($(find "$directory" -mindepth 1 -maxdepth 1 -type d))
  prisoners=()
  for subfolder in "${subfolders[@]}"; do
    prisoners+=("$(basename $subfolder)")
  done
  echo "We have ${#prisoners[@]} prisoners in this prison"

  # Declare an associative array to count the occurrences
  declare -A prisoner_data

  rounds=1
  if [ "$#" -eq 1 ]; then
    rounds=$1
  fi

  prisoners_dilemma_round cake

  for ((r=0; r<$rounds; r++)); do
    prisoners_dilemma_round
  done

  print_prisoner_data > match.log
  log_table_data
  cat prison.log
  echo "Done. If you need to see the score again, check out (prison.log)."
else
  echo "Directory '$directory' does not exist."
fi