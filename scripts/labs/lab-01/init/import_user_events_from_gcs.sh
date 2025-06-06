#!/bin/bash
# Script to import user event data from Cloud Storage into Vertex AI Search for Commerce (Retail API)
# Prerequisites: gcloud CLI and Retail API enabled
source "$(dirname "$0")/../../../env/env.sh"
stage2tmp "./"

# Set variables from environment (exported by Terraform)
PROJECT_ID="${PROJECT_ID:?PROJECT_ID not set}"
RETAIL_BUCKET_NAME="${RETAIL_BUCKET_NAME:?RETAIL_BUCKET_NAME not set}"
USER_EVENTS_FILE="${USER_EVENTS_FILE:?USER_EVENTS_FILE not set}"
CATALOG_ID="${CATALOG_ID:-default_catalog}"
LOCATION="${LOCATION:-global}"

IMPORT_REQUEST_JSON="import_user_events_request.json"

cat > $IMPORT_REQUEST_JSON <<EOF
{
  "inputConfig": {
    "gcsSource": {
      "inputUris": [
        "gs://${RETAIL_BUCKET_NAME}/${USER_EVENTS_FILE}"
      ]
    }
  },
  "errorsConfig": {
    "gcsPrefix": "gs://${RETAIL_BUCKET_NAME}/import_errors/"
  }
}
EOF

echo "Using payload:"
cat $IMPORT_REQUEST_JSON
echo ""

# Call the Retail API to import user events
echo "Submitting import request to Vertex AI Search for Commerce..."
API_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "x-goog-user-project: ${PROJECT_ID}" \
  -H "Content-Type: application/json; charset=utf-8" \
  "https://retail.googleapis.com/v2/projects/${PROJECT_ID}/locations/${LOCATION}/catalogs/${CATALOG_ID}/userEvents:import" \
  -d @$IMPORT_REQUEST_JSON)

rm $IMPORT_REQUEST_JSON

echo "API response:"
echo "$API_RESPONSE" | jq .

# Check the response for errors
if echo "$API_RESPONSE" | jq -e '.error' >/dev/null; then
  echo "Error: Retail API returned an error:"
  echo "$API_RESPONSE" | jq .
  exit 1
fi

echo "Import request submitted. Monitor the operation status in the Google Cloud Console under Vertex AI Search for Commerce > Data."
