# GovWifi Logging API

Session logging for successful authentications

## Overview

Also known as post-auth in Freeradius terms, this logs to the sessions table when a user has authenticated successfuly.

This application is also responsible for sending statistics to the Performance Platform.

### It stores the following details along with this:

- username
- MAC
- Called station ID (Building Identifier)
- Site IP Address

This is useful for debugging and populating last_login of the user.

### Statistics sent over to the performance platform

- Account Usage
- Unique Users

### Sinatra routes

* `GET /healthcheck` - AWS ELB target group health checking
* `GET /logging/post-auth/user/?:username?/mac/?:mac?/ap/?:called_station_id?/site/?:site_ip_address?/result/:authentication_result` - Persist a
  session record with these details

## Developing

### Running the tests

You can run the tests and linter with the following commands:

```shell
make test
make lint
```

### Serving the app locally

```shell
make serve
```

### Deploying changes

Once you have merged your changes into master branch.  Deploying is made up of
two steps.  Pushing a built image to the docker registry from Jenkins, and
restarting the running tasks so it picks up the latest image.
