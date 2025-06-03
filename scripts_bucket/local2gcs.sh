#!/usr/bin/env bash
set -e

BUCKET_ID="artilekt-vaisc-csb_scripts"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

gsutil -m rsync -d -r ${SCRIPT_DIR}/ gs://${BUCKET_ID}/
gsutil ls -R gs://${BUCKET_ID}/