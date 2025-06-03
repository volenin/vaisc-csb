#!/bin/bash

# Source environment variables
echo "[STEP 1] Staging script directory to /tmp and changing to it..."

source "$(dirname "$0")/../../../env/env.sh"
stage2tmp "./"


echo "[STEP 2] Downloading required files from public GCS bucket..."
gsutil cp gs://sureskills-ql/partner-workshops/product-discovery/retail_events.json .
gsutil cp gs://sureskills-ql/partner-workshops/product-discovery/create_recent_events.py .

echo "[STEP 3] Running Python script to generate recent_retail_events.json..."
python3 create_recent_events.py
sleep 10

echo "[STEP 4] Checking if destination bucket exists..."
# create bucket if it doesn't exist
if ! gsutil ls -b "gs://${RETAIL_BUCKET_NAME}" &>/dev/null; then
  echo "Creating bucket ${RETAIL_BUCKET_NAME}..."
  gsutil mb -p "${PROJECT_ID}" -c STANDARD -l "${RETAIL_BUCKET_LOCATION}" "gs://${RETAIL_BUCKET_NAME}"
else
  echo "Bucket ${RETAIL_BUCKET_NAME} already exists."
fi

echo "[STEP 5] Copying generated file to destination bucket..."
# copy the generated file to the bucket
gsutil cp recent_retail_events.json gs://${RETAIL_BUCKET_NAME}