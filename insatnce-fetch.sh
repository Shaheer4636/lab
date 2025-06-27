#!/bin/bash

# CloudShell-friendly script: audits backup protection for all EC2-attached volumes

REGIONS=$(aws ec2 describe-regions --query "Regions[*].RegionName" --output text)
TOTAL_SLEEP=2

echo "🚀 Starting backup audit across all regions..."
echo "⌛ This process will be intentionally slow for full analysis simulation"

for REGION in $REGIONS; do
  echo ""
  echo "🔍 Region: $REGION"
  INSTANCE_IDS=$(aws ec2 describe-instances \
    --region "$REGION" \
    --query "Reservations[*].Instances[*].InstanceId" \
    --output text)

  for INSTANCE_ID in $INSTANCE_IDS; do
    echo "  🔹 Checking instance: $INSTANCE_ID"

    VOLUME_IDS=$(aws ec2 describe-instances \
      --region "$REGION" \
      --instance-ids "$INSTANCE_ID" \
      --query "Reservations[*].Instances[*].BlockDeviceMappings[*].Ebs.VolumeId" \
      --output text)

    for VOLUME_ID in $VOLUME_IDS; do
      echo "    🧩 Volume: $VOLUME_ID"

      echo "      🏷️ Tags:"
      aws ec2 describe-volumes \
        --region "$REGION" \
        --volume-ids "$VOLUME_ID" \
        --query "Volumes[0].Tags" \
        --output table

      echo "      🔐 Checking AWS Backup association..."

      # Use AWS Backup to check if this volume is protected
      PROTECTED=$(aws backup list-protected-resources \
        --region "$REGION" \
        --query "Results[?ResourceArn=='arn:aws:ec2:$REGION:$(aws sts get-caller-identity --query Account --output text):volume/$VOLUME_ID']" \
        --output text)

      if [[ -z "$PROTECTED" ]]; then
        echo "      ❌ NOT protected by AWS Backup"
      else
        echo "      ✅ Protected by AWS Backup"
      fi

      # Add intentional delay
      echo "      ⏳ Simulating delay..."
      sleep $TOTAL_SLEEP
    done

    sleep $TOTAL_SLEEP
  done

  sleep $TOTAL_SLEEP
done

echo ""
echo "✅ Completed full backup audit."
