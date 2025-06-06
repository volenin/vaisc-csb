#!/bin/bash
# env.sh - Source this to set environment variables for import scripts
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Fetch project from gcloud config
export PROJECT_ID="$(gcloud config get-value project 2>/dev/null)"

# Set variables (edit these if your tfvars change)
export SCRIPT_BUCKET_NAME="artilekt-vaisc-csb_scripts"
export RETAIL_DATASET="retail"
export PRODUCTS_TABLE="products"
export CATALOG_ID="default_catalog"
export LOCATION="global"
export USER_EVENTS_FILE="recent_retail_events.json"
export RETAIL_BUCKET_NAME="${PROJECT_ID}_retail"
export RETAIL_BUCKET_LOCATION="us"
export BRANCH_NUMBER_TUTORIAL="1"

export PYTHONPYCACHEPREFIX=$(mktemp -d /tmp/pycache-XXXXXXXX)
# Set LIB_PATH environment variable for downstream scripts
export LIB_PATH="$(cd "$SCRIPT_DIR/../lib" && pwd)"
export ROOT_PATH="$(cd "$SCRIPT_DIR/.." && pwd)"
export PYTHONPATH=$LIB_PATH
export TMP_DIR=$(mktemp -d)
INSTALL_PKG="jq python3-venv"


# Optionally print the variables for debugging
echo "PROJECT_ID=$PROJECT_ID"
echo "SCRIPT_BUCKET_NAME=$SCRIPT_BUCKET_NAME"
echo "RETAIL_DATASET=$RETAIL_DATASET"
echo "PRODUCTS_TABLE=$PRODUCTS_TABLE"
echo "CATALOG_ID=$CATALOG_ID"
echo "LOCATION=$LOCATION"
echo "USER_EVENTS_FILE=$USER_EVENTS_FILE"
echo "RETAIL_BUCKET_NAME=$RETAIL_BUCKET_NAME"
echo "RETAIL_BUCKET_LOCATION=$RETAIL_BUCKET_LOCATION"
echo "BRANCH_NUMBER_TUTORIAL=$BRANCH_NUMBER_TUTORIAL"
echo "PYTHONPYCACHEPREFIX=$PYTHONPYCACHEPREFIX"
echo "LIB_PATH=$LIB_PATH"
echo "ROOT_PATH=$ROOT_PATH"
echo "PYTHONPATH=$PYTHONPATH"
echo "TMP_DIR=$TMP_DIR"

# List of additional packages to install


# Ensure required packages are installed for JSON parsing and other utilities
for pkg in $INSTALL_PKG; do
  if ! command -v $pkg &> /dev/null; then
    echo "[INFO] Installing missing package: $pkg"
    if [ "$(id -u)" -eq 0 ]; then
      apt-get install -y -q $pkg
    else
      sudo apt-get install -y -q $pkg
    fi
  else
    echo "[INFO] Package already installed: $pkg"
  fi
done

# Create and activate Python virtual environment if not already active
if [ -z "$VIRTUAL_ENV" ]; then
  VENV_DIR="$TMP_DIR/venv"
  if [ ! -d "$VENV_DIR" ]; then
    echo "[INFO] Creating Python virtual environment at $VENV_DIR"
    python3 -m venv "$VENV_DIR"
  fi
  echo "[INFO] Activating Python virtual environment at $VENV_DIR"
  # shellcheck disable=SC1090
  source "$VENV_DIR/bin/activate"
else
  echo "[INFO] Using already active Python virtual environment: $VIRTUAL_ENV"
fi

# Install Python dependencies from requirements.txt if present
REQ_FILE="$LIB_PATH/requirements.txt"
if [ -f "$REQ_FILE" ]; then
  echo "[INFO] Installing Python dependencies from $REQ_FILE"
  pip install -r "$REQ_FILE"
else
  echo "[WARNING] requirements.txt not found at $REQ_FILE"
fi

# Function to copy a directory recursively to /tmp and cd into it
stage2tmp() {
  local src_dir="$1"
  local tmp_dir
  tmp_dir=$TMP_DIR
  cp -r "$src_dir"/* "$tmp_dir"/
  cd "$tmp_dir" || return 1
}
