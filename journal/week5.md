# Week 5 — DynamoDB and Serverless Caching


## Week 5 DynamoDb Utility Scrips
- Renaming and relocating the scripts files
- adding boto3 in requirements.txt file
- installing the boto3 by using command 
    "pip install -r requirements.txt"
- uncomment the dynanmodb from the docker-compose
- create other few bash files for dynamoDb in "backend-flask/bin/ddb"
- updated the path of update-sg-rule in "gitpod.yml" file.

Reference for creating table:
https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/dynamodb/client/create_table.html


- first file which is created as 
```  "./bin/ddb/schema-load"

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
- Run this script to create the table as "cruddur messages"
![result of schema-load script](../_docs/assets/result-of-schema-load-script.JPG)

Reference for listing tables:
https://docs.aws.amazon.com/cli/latest/reference/dynamodb/list-tables.html
- After that we created another bach script by which we can see the tables inside the db;
```"./bin/ddb/list-table"

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

- Run this script to list out the table we just created
![result of list-table script](../_docs/assets/result-of-list-table-script.JPG)

- After that we will create our dynamDB seed script file
"./bin/ddb/seed"

- After that we will need to run our setup script from db folder "./bin/db/setup" to poulate our seed.sql into the db
- Note: Fixed the path in setup script and insert statement which was missing email to make it work.
- Run the seed file "./bin/ddb/seed" to seed the data into "cruddur-messages" table

- We create our scan script file "./bin/ddb/scan" and run it to check if the data is present inside the "cruddur-messages" table.
![result of scan script](../_docs/assets/result-of-scan-script.JPG)

- Also we created further pattern scripts "./bin/ddb/patterns/get-conversation" & "./bin/ddb/patterns/list-conversation"
- Ran the "./bin/ddb/patterns/get-conversation" to get the conversation
![result of get conversation script](../_docs/assets/get-of-list-conversation-script.JPG)

- Ran the "./bin/ddb/patterns/list-conversation" but it throw an error

- To fix this we will go back to our "lib/db.py" file and add new functionn to make it fun which will make it work and throw conversation into the cli

![result of list conversation script](../_docs/assets/result-of-list-conversation-script.JPG)

