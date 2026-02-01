#!/bin/bash
# Merge coverage files from all packages into a single lcov.info file

set -e

echo "Merging coverage files..."

# Find all lcov.info files
COVERAGE_FILES=$(find . -name "lcov.info" -path "*/coverage/*" | tr '\n' ' ')

if [ -z "$COVERAGE_FILES" ]; then
  echo "No coverage files found!"
  exit 1
fi

# Create merged coverage directory
mkdir -p coverage_merged

# Merge all coverage files
lcov \
  --add-tracefile $(echo $COVERAGE_FILES | sed 's/ / --add-tracefile /g') \
  --output-file coverage_merged/lcov.info

echo "Coverage files merged successfully!"
echo "Merged coverage file: coverage_merged/lcov.info"

# Display coverage summary
lcov --summary coverage_merged/lcov.info
