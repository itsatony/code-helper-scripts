#!/bin/bash

set -euo pipefail

# Default values
base_path="."
include_patterns=()
exclude_patterns=()
output_file="filepaths.md"

# Function to print usage
usage() {
    echo "Usage: $0 [base_path] [-i include_pattern ...] [-e exclude_pattern ...] [-o output_file]"
    echo "  base_path: Base path to start from (default: current directory)"
    echo "  -i: Include pattern(s) (glob-style, can be used multiple times)"
    echo "  -e: Exclude pattern(s) (glob-style, can be used multiple times)"
    echo "  -o: Output file name (default: filepaths.md)"
    exit 1
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -i) include_patterns+=("$2"); shift 2 ;;
        -e) exclude_patterns+=("$2"); shift 2 ;;
        -o) output_file="$2"; shift 2 ;;
        -h) usage ;;
        -*) echo "Unknown option: $1" >&2; usage ;;
        *) base_path="$1"; shift ;;
    esac
done

# Change to the base path
cd "$base_path" || exit 1

# Prepare find command
find_cmd="find ."

# Add exclude patterns to find command
for pattern in "${exclude_patterns[@]}"; do
    find_cmd="$find_cmd -not -path './$pattern'"
done

# Add include patterns to find command
if [ ${#include_patterns[@]} -eq 0 ]; then
    find_cmd="$find_cmd -type f"
else
    find_cmd="$find_cmd \( -false"
    for pattern in "${include_patterns[@]}"; do
        find_cmd="$find_cmd -o -path './$pattern'"
    done
    find_cmd="$find_cmd \) -type f"
fi

# Generate the markdown content
{
    echo "## Filepaths"
    echo
    eval "$find_cmd" | sed 's|^\./||' | sort | sed 's/^/* /'
} > "$output_file"

echo "Markdown file generated: $output_file"
