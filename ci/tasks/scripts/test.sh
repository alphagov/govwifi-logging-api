#!/bin/bash

./govwifi-admin/ci/tasks/scripts/with-docker.sh

workspace_dir="${PWD}"
cd govwifi-admin || exit

make test

cd "${workspace_dir}" || exit
