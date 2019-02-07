# GovWifi Logging API

The GovWifi frontend uses this API to record each session with successful authentications.
N.B. The private GovWifi [build repository][build-repo] contains instructions on how to build GovWifi end-to-end - the sites, services and infrastructure.

## Overview

Also known as `post-auth` in FreeRadius terms, this logs to the sessions table when a user has authenticated successfully.

During the RADIUS `post-auth` action, a POST request is sent to this API containing session data. This API receives this request and saves it to a database.

This application is also responsible for sending statistics to the Performance Platform.

It stores the following details along with this:

- username
- MAC
- Called station ID (Building Identifier)
- Site IP Address

This is useful for debugging and populating last_login of the user.

### Statistics sent over to the performance platform

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

### Sinatra routes

* `GET /healthcheck` - AWS ELB target group health checking
* `GET /logging/post-auth/user/?:username?/mac/?:mac?/ap/?:called_station_id?/site/?:site_ip_address?/result/:authentication_result` - Persist a
  session record with these details

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

Once you have merged your changes into master branch, deploying them is made up of
two steps:

* Pushing a built image to the docker registry from Jenkins.

* Restarting the running tasks so it picks up the latest image.

## Licence

This codebase is released under [the MIT License][mit].

[mit]: LICENCE
[build-repo]:https://github.com/alphagov/govwifi-build
