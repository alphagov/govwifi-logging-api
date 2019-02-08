# GovWifi Logging API

The GovWifi frontend uses this API to record each authentication request. It is stored in a database and this data is used for reporting and debugging.
N.B. The private GovWifi [build repository][build-repo] contains instructions on how to build GovWifi end-to-end - the sites, services and infrastructure.

## Table of Contents

- [Overview](#overview)
  - [Sinatra routes](#sinatra-routes)
  - [Statistics sent over to the performance platform](#statistics-sent-over-to-the-performance-platform)
    - [Send statistics manually](#send-statistics-manually)
      - [Account Usage](#account-usage)
      - [Unique Users](#unique-users)
- [Developing](#developing)
  - [Running the tests](#running-the-tests)
  - [Using the linter](#using-the-linter)
  - [Serving the app locally](#serving-the-app-locally)
  - [Deploying changes](#deploying-changes)
- [Licence](#licence)

## Overview

Also known as `post-auth` in FreeRadius terms, this logs to the sessions table when a user has authenticated successfully or unsuccessfully.

During the RADIUS `post-auth` action, a POST request is sent to this API containing session data. This API receives this request and saves it to a database.

This application is also responsible for sending statistics to the Performance Platform.

It stores the following details along with this:

- username
- MAC
- Called station ID (Building Identifier)
- Site IP Address

This is useful for debugging and populating last_login of the user.

### Sinatra routes

- `POST /healthcheck` - AWS ELB target group health checking
- `POST /logging/post-auth/user/?:username?/mac/?:mac?/ap/?:called_station_id?/site/?:site_ip_address?/result/:authentication_result` - Persist a
  session record with these details

## Statistics sent over to the performance platform

- Account Usage
- Unique Users

### Send statistics manually

You can trigger statistics to be sent manually by running the command below locally.
Ensure that your ~/.aws/credentials is set up correctly.
Populate the date argument to the Rake task with the date that you want to send the statistics for.

#### Account Usage

```shell
aws ecs run-task --cluster wifi-api-cluster --task-definition logging-api-task-wifi --count 1 --overrides "{ \"containerOverrides\": [{ \"name\": \"logging\", \"command\": [\"bundle\", \"exec\", \"rake\", \"publish_daily_statistics['2018-09-24']\"] }] }" --region eu-west-2
```

#### Unique Users

```shell
aws ecs run-task --cluster wifi-api-cluster --task-definition logging-api-task-wifi --count 1 --overrides "{ \"containerOverrides\": [{ \"name\": \"logging\", \"command\": [\"bundle\", \"exec\", \"rake\", \"publish_weekly_statistics['2018-09-24']\"] }] }" --region eu-west-2
```

## Developing

### Running the tests

```shell
make test
```

### Using the linter

```shell
make lint
```

### Serving the app locally

```shell
make serve
```

### Deploying changes

Merging to `master` will automatically deploy this API to staging.
To deploy to production, choose _Deploy to production_ in the jenkins pipeline when prompted.

## Licence

This codebase is released under [the MIT License][mit].

[mit]: LICENCE
[build-repo]:https://github.com/alphagov/govwifi-build
