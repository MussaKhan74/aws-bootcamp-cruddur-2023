-- https://www.postgresql.org/docs/current/uuid-ossp.html
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;

-- export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
-- gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"

-- export PROD_CONNECTION_URL="postgresql://CruddurRoot:CruddurDbPassword123@cruddur-db-instance.cknnslnpfvvr.us-east-1.rds.amazonaws.com:5432/cruddur"
-- gp env PROD_CONNECTION_URL="postgresql://CruddurRoot:CruddurDbPassword123@cruddur-db-instance.cknnslnpfvvr.us-east-1.rds.amazonaws.com:5432/cruddur"


CREATE TABLE public.users (
  uuid UUID default uuid_generate_v4() primary key,
  display_name text,
  handle text,
  cognito_user_id text,
  created_at timestamp default current_timestamp NOT NULL
);

CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID NOT NULL,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);