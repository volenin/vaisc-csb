#!/bin/bash
# wrapper.sh - Executes all initialization job scripts sequentially
# This wrapper is triggered by a single Cloud Scheduler job

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Log start
echo "=========================================="
echo "Starting VAISC Lab-01 Initialization"
echo "Time: $(date)"
echo "=========================================="

# Track overall success
OVERALL_SUCCESS=0

# Find and execute all .job files in the current directory
cd "$SCRIPT_DIR"
for job in *.job; do
  # Skip if no .job files found (glob doesn't expand)
  if [ ! -f "$job" ]; then
    echo "WARNING: No .job files found in $SCRIPT_DIR"
    break
  fi

  echo ""
  echo "------------------------------------------"
  echo "Running: $job"
  echo "Started at: $(date)"
  echo "------------------------------------------"

  # Execute the job script (no chmod needed - GCS mount is read-only, bash executes directly)
  if bash "$job"; then
    echo "✓ SUCCESS: $job completed successfully"
  else
    EXIT_CODE=$?
    echo "✗ FAILED: $job exited with code $EXIT_CODE"
    OVERALL_SUCCESS=1
    # Continue with next job even if this one fails
  fi

  echo "Completed at: $(date)"
done

# Final summary
echo ""
echo "=========================================="
echo "VAISC Lab-01 Initialization Complete"
echo "Time: $(date)"
if [ $OVERALL_SUCCESS -eq 0 ]; then
  echo "Status: ALL JOBS COMPLETED SUCCESSFULLY"
else
  echo "Status: SOME JOBS FAILED (see log above)"
fi
echo "=========================================="

exit $OVERALL_SUCCESS
