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

``` "Run these commands in CLI to create cloud-watch group"
aws logs create-log-group --log-group-name "/cruddur/fargate-cluster"
aws logs put-retention-policy --log-group-name "/cruddur/fargate-cluster" --retention-in-days 1
```
![result of cloud-watch-log-confirmation](../_docs/assets/cloud-watch-log.JPG)

- We will create our ECS (Amazon Elastic Container Service) by running following CLI Commands

```"Run these commands in CLI to create ECS"
aws ecs create-cluster \
--cluster-name cruddur \
--service-connect-defaults namespace=cruddur
```
![result of ecs-creation-confirmation](../_docs/assets/ecs-creation-confirmation.JPG)

![result of aws-dashboard-ecs-result](../_docs/assets/aws-dashboard-ecs-result.JPG)

- Now we are going to create our ECR (Amazon Elastic Container Registry) for our containers.
- Note: Instead of pulling python or node image directly from the docker registry we are going to push them to our ECR Repo because sometimes docker registry is going to give us error e.g. your pulling this image-name too many etc
- First we are going to push our python repository using cli commands

```"Run these commands in CLI to create ECR repo for base-image python"

aws ecr create-repository \
  --repository-name cruddur-python \
  --image-tag-mutability MUTABLE
```
![result of python-baseimage-ecr-confirmation](../_docs/assets/python-baseimage-ecr-confirmation.JPG)
![result of ecr-python-repo-aws-dashboard](../_docs/assets/ecr-python-repo-aws-dashboard.JPG)


- After that we are going to confirm from aws dashboard that our repo for python image is created or note. 
- We need to check AWS ECR dashboard > Repositories > Repo Name (cruddur-python) > View Push Commands
- This will show us the command to build our python image 
- We will set our env variable of ECR_PYTHON_URL

``` "run this command in cli for setting env var for ecr-python-repository"
export ECR_PYTHON_URL="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/cruddur-python"
```

``` "run this command in cli for Pulling python image from docker"
docker pull python:3.10-slim-buster
```

``` "run this command in cli tagging our python image"
docker tag python:3.10-slim-buster $ECR_PYTHON_URL:3.10-slim-buster
```

``` "run this command in cli to push our local docker image to aws ECR repository of python "
docker push $ECR_PYTHON_URL:3.10-slim-buster
```

- NOTE: before pushing the image we need to go AWS ECR dashboard > Repositories > Repo Name (cruddur-python) > View Push Commands > Copy the Login credentials so you are able to push your repo or else it would end up giving you error "no basic auth credential".

![result of ecr-python-image-push-result](../_docs/assets/ecr-python-image-push-result.JPG)



