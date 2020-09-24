# GovWifi Logging API

The GovWifi frontend uses this API to record each authentication request. It is stored in a database and this data is used for reporting and debugging.

N.B. The private GovWifi [build repository][build-repo] contains instructions on how to build GovWifi end-to-end - the sites, services and infrastructure.

## Table of Contents

- [Overview](#overview)
  - [Sinatra routes](#sinatra-routes)
  - [Statistics sent over to S3](#statistics-sent-over-to-s3)
    - [Send statistics manually](#send-statistics-manually)
      - [Account Usage](#account-usage)
      - [Unique Users](#unique-users)
- [Developing](#developing)
  - [Deploying changes](#deploying-changes)
- [Licence](#licence)

## Overview

Also known as `post-auth` in FreeRadius terms, this logs to the sessions table when a user has authenticated successfully or unsuccessfully.

During the RADIUS `post-auth` action, a POST request is sent to this API containing session data. This API receives this request and saves it to a database.

This application is also responsible for sending statistics to S3.

It stores the following details along with this:

- username
- MAC
- Called station ID (Building Identifier)
- Site IP Address

This is useful for debugging and populating last_login of the user.

### Sinatra routes

- `GET /healthcheck` - AWS ELB target group health checking
- `POST /logging/post-auth` - Persist a session record with these details:

```shell
params:
  :username
  :mac
  :called_station_id
  :site_ip_address
  :authentication_result
```

## Statistics sent over to S3

- Account Usage
- Unique Users

### Send statistics manually

You can trigger statistics to be sent manually by running the command below locally.
Ensure that your ~/.aws/credentials is set up correctly.
Populate the date argument to the Rake task with the date that you want to send the statistics for.

#### Weekly Statistics

```shell
aws ecs run-task --cluster wifi-api-cluster --task-definition logging-api-task-wifi --count 1 --overrides "{ \"containerOverrides\": [{ \"name\": \"logging\", \"command\": [\"bundle\", \"exec\", \"rake\", \"publish_weekly_statistics['2018-12-01']\"] }] }" --network-configuration "{ \"awsvpcConfiguration\": { \"assignPublicIp\": \"ENABLED\", \"subnets\": [\"subnet-XXXXXXX\", \"subnet-XXXXXX\"],\"securityGroups\": [\"sg-XXXXXX\"]}}" --region eu-west-2 --launch-type FARGATE
```

#### Monthly Statistics

```shell
aws ecs run-task --cluster wifi-api-cluster --task-definition logging-api-task-wifi --count 1 --overrides "{ \"containerOverrides\": [{ \"name\": \"logging\", \"command\": [\"bundle\", \"exec\", \"rake\", \"publish_monthly_statistics['2018-12-01']\"] }] }" --network-configuration "{ \"awsvpcConfiguration\": { \"assignPublicIp\": \"ENABLED\", \"subnets\": [\"subnet-XXXXXXX\", \"subnet-XXXXXX\"],\"securityGroups\": [\"sg-XXXXXX\"]}}" --region eu-west-2 --launch-type FARGATE
```

## Developing

The [Makefile](Makefile) contains commonly used commands for working with this app:

- `make test` runs all the automated tests.
- `make serve` starts the API server on localhost.
- `make lint` runs the gov-uk linter.

### Deploying changes

Merging to `master` will automatically deploy this API to staging.
To deploy to production, choose _Deploy to production_ in the Concourse Pipeline.

## Licence

This codebase is released under [the MIT License][mit].

[mit]: LICENCE
[build-repo]: https://github.com/alphagov/govwifi-build
