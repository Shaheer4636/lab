#!/bin/bash

# Set tag key and value
TAG_KEY="project"
TAG_VALUE="lib"

# Get all resource IDs in the current subscription
echo "[+] Fetching all resource IDs..."
RESOURCE_IDS=$(az resource list --query "[].id" -o tsv)

echo "[+] Applying tag to all resources..."

# Loop through all resources and apply the tag
for RESOURCE_ID in $RESOURCE_IDS; do
  echo "Tagging: $RESOURCE_ID"
  az resource tag \
    --ids "$RESOURCE_ID" \
    --tags $TAG_KEY=$TAG_VALUE \
    --only-show-errors
done

echo "[✓] Tagging complete."
