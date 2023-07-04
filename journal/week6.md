# Week 6 — Deploying Containers

## ECS FARGATE
- We need to have health check for different things like dbs, containers etc. So for that we are going to create scripts to check them out.

- We need to create a test file for our rds; 
```  "./bin/db/test"

#!/usr/bin/env python3

import psycopg
import os
import sys

connection_url = os.getenv("CONNECTION_URL")

conn = None
try:
  print('attempting connection')
  conn = psycopg.connect(connection_url)
  print("Connection successful!")
except psycopg.Error as e:
  print("Unable to connect to the database:", e)
finally:
  conn.close()
```
![result of bin-rds-test-confirmation](../_docs/assets/bin-rds-test-confirmation.JPG)

- after that we are going to run our security rule group script and and run our above test script and it will show success message.

- we are also going to make test url endpoint for our flask app to do a health check for which;

``` "backend-flask/app.py | line 128 - 130"

@app.route('/api/health-check')
def health_check():
  return {'success': True}, 200
```
- and create a new script for flask app to check health

```"./bin/flask/health-check"

#!/usr/bin/env python3

import urllib.request

try:
  response = urllib.request.urlopen('http://localhost:4567/api/health-check')
  if response.getcode() == 200:
    print("[OK] Flask server is running")
    exit(0) # success
  else:
    print("[BAD] Flask server is not running")
    exit(1) # false
# This for some reason is not capturing the error....
#except ConnectionRefusedError as e:
# so we'll just catch on all even though this is a bad practice
except Exception as e:
  print(e)
  exit(1) # false
```

- Note: We could have used bash script and used curl instead of python script but docker container doesn't have curl or any networking debugging tools by default so it will create a security risk for your container and someone can easily access.

- We will also enable the cloud log for our application and change it's retention time to 1 day to keep our cost minimum. Note: Usually we don't keep the retention time to 1 day but it is just to save our logging cost.

``` "Run this commands in CLI to create cloud-watch group"
aws logs create-log-group --log-group-name "/cruddur/fargate-cluster"
aws logs put-retention-policy --log-group-name "/cruddur/fargate-cluster" --retention-in-days 1
```
![result of cloud-watch-log-confirmation](../_docs/assets/cloud-watch-log.JPG)


