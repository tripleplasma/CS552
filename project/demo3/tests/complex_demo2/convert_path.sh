#!/bin/bash

# Check if a directory is provided as an argument, otherwise use the current directory
directory="${1:-.}"

# Output file name
output_file="all.list"

# Find all .asm files and write their absolute paths to the .list file
find "$directory" -type f -name "*.asm" -exec realpath {} \; > "$output_file"

echo "Absolute paths of .asm files have been written to $output_file"
