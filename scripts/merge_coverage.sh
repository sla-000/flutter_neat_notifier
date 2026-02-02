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
echo "Calculating detailed summary..."
lcov --summary coverage_merged/lcov.info | tee coverage_merged/summary.txt

# Extract and print total percentage
# Example line: "  lines......: 92.5% (123 of 133 lines)"
TOTAL_PERCENT=$(grep "lines" coverage_merged/summary.txt | grep -oE "[0-9]+(\.[0-9]+)?%")

echo ""
echo "======================================================="
echo "  TOTAL PROJECT COVERAGE: $TOTAL_PERCENT"
echo "======================================================="
echo ""
