#!/bin/bash
# Script to import Retail products schema data from BigQuery into Vertex AI Search for Commerce (Retail API)
# Prerequisites: gcloud CLI, jq, and API enabled
source "$(dirname "$0")/../../../env/env.sh"
stage2tmp "./"

# Set variables from environment
PROJECT_ID="${PROJECT_ID:?PROJECT_ID not set}"
RETAIL_DATASET="${RETAIL_DATASET:?RETAIL_DATASET not set}"
PRODUCTS_TABLE="${PRODUCTS_TABLE:?PRODUCTS_TABLE not set}"
CATALOG_ID="${CATALOG_ID:-default_catalog}"
LOCATION="${LOCATION:-global}"

# Import request JSON
IMPORT_REQUEST="import_request.json"
cat > $IMPORT_REQUEST <<EOF
{
  "inputConfig": {
    "bigQuerySource": {
      "projectId": "${PROJECT_ID}",
      "datasetId": "${RETAIL_DATASET}",
      "tableId": "${PRODUCTS_TABLE}"
    }
  }
}
EOF

# Check if data has been successfully imported to retail api already and run the import only if not
# PRODUCTS_LIST_URL="https://retail.googleapis.com/v2/projects/${PROJECT_ID}/locations/${LOCATION}/catalogs/${CATALOG_ID}/branches/default_branch/products"
# if curl -s -X GET \
#   -H "Authorization: Bearer $(gcloud auth print-access-token)" \
#   -H "x-goog-user-project: ${PROJECT_ID}" \
#   -H "Content-Type: application/json" \
#   "${PRODUCTS_LIST_URL}" \
#   | jq -e '.products | length > 0' >/dev/null; then
#   echo "Products already imported. Skipping import."
#   exit 0
# fi

# Call the Retail API to import products
API_RESPONSE=$(curl -s -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "x-goog-user-project: ${PROJECT_ID}" \
  -H "Content-Type: application/json" \
  "https://retail.googleapis.com/v2/projects/${PROJECT_ID}/locations/${LOCATION}/catalogs/${CATALOG_ID}/branches/default_branch/products:import" \
  -d @$IMPORT_REQUEST)

# Check the response for errors
if echo "$API_RESPONSE" | jq -e '.error' >/dev/null; then
  echo "Error: Retail API returned an error:"
  echo "$API_RESPONSE" | jq .
  exit 1
fi

echo "Import request submitted. Check the Vertex AI Search for Commerce console for status."
