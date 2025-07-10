#!/bin/bash

# Set your desired tag
TAG_KEY="project"
TAG_VALUE="liberty"

echo "[*] Fetching all AWS regions..."
REGIONS=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

# Loop through all regions
for REGION in $REGIONS; do
  echo -e "\n[+] Processing region: $REGION"
  
  # Get all resource ARNs in this region
  RESOURCE_ARNS=$(aws resourcegroupstaggingapi get-resources \
    --region "$REGION" \
    --query "ResourceTagMappingList[].ResourceARN" \
    --output text)

  if [ -z "$RESOURCE_ARNS" ]; then
    echo "[-] No resources found in $REGION"
    continue
  fi

  for ARN in $RESOURCE_ARNS; do
    echo "[+] Tagging $ARN with $TAG_KEY=$TAG_VALUE"
    aws resourcegroupstaggingapi tag-resources \
      --region "$REGION" \
      --resource-arn-list "$ARN" \
      --tags $TAG_KEY=$TAG_VALUE \
      --output text
  done
done

echo -e "\n[✓] Tagging completed across all regions."
