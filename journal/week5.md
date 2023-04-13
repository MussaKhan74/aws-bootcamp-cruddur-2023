# Week 5 — DynamoDB and Serverless Caching

-- Renaming and relocating the scripts files
-- adding boto3 in requirements.txt file
-- installing the boto3 by using command 
    "pip install -r requirements.txt"
-- uncomment the dynanmodb from the docker-compose
-- create other few bash files for dynamoDb in "backend-flask/bin/ddb"
-- updated the path of update-sg-rule in "gitpod.yml" file.

Reference for creating table:
https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb/client/create_table.html


-- first file which is created is 
    "schema-load"
```
#!/usr/bin/env python3

import boto3
import sys

attrs = {
  'endpoint_url': 'http://localhost:8000'
}

if len(sys.argv) == 2:
  if "prod" in sys.argv[1]:
    attrs = {}

ddb = boto3.client('dynamodb',**attrs)

table_name = 'cruddur-messages'


response = ddb.create_table(
  TableName=table_name,
  AttributeDefinitions=[
    {
      'AttributeName': 'pk',
      'AttributeType': 'S'
    },
    {
      'AttributeName': 'sk',
      'AttributeType': 'S'
    },
  ],
  KeySchema=[
    {
      'AttributeName': 'pk',
      'KeyType': 'HASH'
    },
    {
      'AttributeName': 'sk',
      'KeyType': 'RANGE'
    },
  ],
  #GlobalSecondaryIndexes=[
  #],
  BillingMode='PROVISIONED',
  ProvisionedThroughput={
      'ReadCapacityUnits': 5,
      'WriteCapacityUnits': 5
  }
)

print(response)
```
-- Run this script to create the table as "cruddur messages"

Reference for listing tables:
https://docs.aws.amazon.com/cli/latest/reference/dynamodb/list-tables.html
-- After that we created another bach script by which we can see the tables inside the db;
"bin/ddb/list-table"

```
#! /usr/bin/bash
set -e # stop if it fails at any point

if [ "$1" = "prod" ]; then
  ENDPOINT_URL=""
else
  ENDPOINT_URL="--endpoint-url=http://localhost:8000"
fi

aws dynamodb list-tables $ENDPOINT_URL \
--query TableNames \
--output table
```

--Run this script to list out the table we just created
