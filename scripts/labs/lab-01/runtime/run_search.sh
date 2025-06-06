#!/bin/bash
# run_search.sh - Wrapper to source env.sh and run the Python search function

# Source environment variables
SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/../../../env/env.sh"

# Set LIB_PATH environment variable
# export LIB_PATH="$SCRIPT_DIR/../../../lib"

# Run the Python script (calls search() by default)
cd "$LIB_PATH"
python3 "search/search_simple_query.py"