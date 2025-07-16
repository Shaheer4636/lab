#!/bin/bash

echo "========== Untagged AWS Resources =========="
echo -e "ResourceType\tResourceIdentifier"
echo -e "------------\t------------------"

# EC2 Instances
for instance_id in $(aws ec2 describe-instances --query "Reservations[].Instances[].InstanceId" --output text); do
  tags=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$instance_id" --query "Tags" --output json)
  if [ "$tags" == "[]" ]; then
    echo -e "EC2\t\t$instance_id"
  fi
done

# RDS Instances
for db in $(aws rds describe-db-instances --query "DBInstances[].DBInstanceIdentifier" --output text); do
  arn=$(aws rds describe-db-instances --db-instance-identifier "$db" --query "DBInstances[0].DBInstanceArn" --output text)
  tags=$(aws rds list-tags-for-resource --resource-name "$arn" --query "TagList" --output json)
  if [ "$tags" == "[]" ]; then
    echo -e "RDS\t\t$db"
  fi
done

# S3 Buckets
for bucket in $(aws s3api list-buckets --query "Buckets[].Name" --output text); do
  tags=$(aws s3api get-bucket-tagging --bucket "$bucket" --query "TagSet" --output json 2>/dev/null)
  if [ -z "$tags" ] || [ "$tags" == "[]" ]; then
    echo -e "S3\t\t$bucket"
  fi
done

# Lambda Functions
for func in $(aws lambda list-functions --query "Functions[].FunctionName" --output text); do
  arn=$(aws lambda get-function --function-name "$func" --query "Configuration.FunctionArn" --output text)
  tags=$(aws lambda list-tags --resource "$arn" --query "Tags" --output json)
  if [ "$tags" == "{}" ]; then
    echo -e "Lambda\t\t$func"
  fi
done
