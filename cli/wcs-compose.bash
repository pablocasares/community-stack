#!/usr/bin/env bash

# Wizzie Community Stack - The lightweight Wizzie Data Platform (WDP)
# Copyright (C) 2018 Wizzie S.L.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o pipefail
script_name=$(basename -s '.bash' "$0")
declare -r script_name

if [[ $# -gt 0 && ($1 == '--shorthelp' || $1 == '--help' ) ]]; then
    declare message
    case "${script_name}" in
    wcs-start)
        message='Start Wizzie community stack services'
        ;;
    wcs-stop)
        message='Stop Wizzie community stack services'
        ;;
    wcs-up)
        message='(re)Create and start Wizzie community stack services'
        ;;
    wcs-down)
        message='Stop Wizzie community stack services services and remove kafka queue'
        ;;
    wcs-logs)
        message='View output from connectors'
        ;;
    wcs-compose|*)
        message='Send generic commands to Wizzie community stack docker compose'
        ;;
    esac
    printf '%s\n' "$message"
    exit 0
fi

declare action="${script_name#wcs-}"
if [[ $action == 'compose' ]]; then
    unset -v action
fi

declare compose_files=()
for yaml in "${PREFIX}/share/wcs/compose/"*.yaml; do
    compose_files+=(--file "$yaml")
done

# Needed for .env file location
# TODO test docker-compose --project-directory
cd "${PREFIX}/etc/wcs" || exit 1

# Need to not to quote action in order to not to pass empty string argument
# shellcheck disable=SC2086
docker-compose \
    --project-name wizz-comm-stack \
    "${compose_files[@]}" ${action} "$@"
