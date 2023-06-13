#!/bin/bash

# Declare an associative array
declare -A data

# Example data
data["category1:item1"]="value1"
data["category1:item2"]="value2"
data["category2:item3"]="value3"
data["category2:item4"]="value4"

# Access and modify associative array elements
data["category1:item2"]="new_value2"
data["category2:item4"]="new_value4"

s="as"
test="&{data[$s]}"

# Display the associative array
for key in "${!data[@]}"; do
  value="${data[$key]}"
  echo "Key: $key, Value: $value"
done
