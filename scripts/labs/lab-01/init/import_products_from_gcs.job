#!/bin/bash
# run_search.sh - Wrapper to source env.sh and run the Python search function

# Source environment variables
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/../../../env/env.sh"

# Copy all files from SCRIPT_BUCKET/resources to RETAIL_BUCKET
gsutil -m cp -r "gs://${SCRIPT_BUCKET_NAME}/resources/*" "gs://${RETAIL_BUCKET_NAME}/"

# Set LIB_PATH environment variable
# export LIB_PATH="$SCRIPT_DIR/../../../lib"

# Run the Python script (calls search() by default)
cd "$LIB_PATH"
python3 "data/import_products_gcs.py"