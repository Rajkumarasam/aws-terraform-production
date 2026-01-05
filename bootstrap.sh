#!/bin/bash

# CONFIGURATION
# Change this bucket name if it fails (must be globally unique)
BUCKET_NAME="raj-ecommerce-state-2026-v2" 
TABLE_NAME="ecommerce-terraform-lock"
REGION="ap-south-1"

echo "------------------------------------------------"
echo "🚀 Starting Infrastructure Bootstrap..."
echo "Region: $REGION"
echo "Bucket: $BUCKET_NAME"
echo "------------------------------------------------"

# 1. CREATE S3 BUCKET
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "✅ S3 Bucket already exists."
else
    echo "⏳ Creating S3 Bucket..."
    aws s3 mb "s3://$BUCKET_NAME" --region "$REGION"
    
    # Enable Versioning (Safety Net)
    aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
    echo "✅ Bucket created & Versioning Enabled."
fi

# 2. CREATE DYNAMODB TABLE
if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" >/dev/null 2>&1; then
    echo "✅ DynamoDB Table already exists."
else
    echo "⏳ Creating DynamoDB Table..."
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
        --region "$REGION"
    echo "✅ Table created successfully."
fi

echo "------------------------------------------------"
echo "🎉 Bootstrap Complete!"
