#!/bin/bash

set -e

apt-get install jq -y

echo "Waiting for LocalStack DynamoDB to be ready..."
until curl -s http://localhost:4566/_localstack/health | jq -e '.services.dynamodb == "available"' > /dev/null; do
  sleep 2
done
echo "DynamoDB is ready."


ENDPOINT=http://localstack:4566
TABLE_NAME=CurrencyRates
LAMBDA_NAME=USDHandlerFunction

echo "Building .NET Lambda..."
cd /app/lambda
dotnet restore
dotnet lambda package --output-package function.zip
cd ..

echo "Creating DynamoDB table..."
aws --endpoint-url=$ENDPOINT dynamodb create-table \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --stream-specification StreamEnabled=true,StreamViewType=NEW_AND_OLD_IMAGES

STREAM_ARN=$(aws --endpoint-url=$ENDPOINT dynamodb describe-table \
  --table-name $TABLE_NAME \
  --query "Table.LatestStreamArn" --output text)

echo "Creating Lambda function..."
aws --endpoint-url=$ENDPOINT lambda create-function \
  --function-name $LAMBDA_NAME \
  --runtime dotnet8 \
  --handler USDHandlerFunction::USDHandlerFunction.Function::FunctionHandler \
  --zip-file fileb://lambda/function.zip \
  --role arn:aws:iam::000000000000:role/lambda-role

echo "Creating event source mapping with filter..."
aws --endpoint-url=$ENDPOINT lambda create-event-source-mapping \
  --function-name $LAMBDA_NAME \
  --event-source-arn $STREAM_ARN \
  --starting-position LATEST \
  --filter-criteria '{
    "Filters": [
      {
        "Pattern": "{\"dynamodb\":{\"NewImage\":{\"currency_code\":{\"S\":[\"USD\"]}}}}"
      }
    ]
  }'
