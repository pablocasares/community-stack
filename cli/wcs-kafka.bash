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

# Main kafka wcs CLI entrypoint
# Arguments:
#  [--shorthelp] - Show one line help
#  [-h/--help] - Show help
#
# Environment
#  - PREFIX: wcs installation location
#
# Out:
#  UI
#
# Exit status:
#  Subcommand exit status

. "${BASH_SOURCE%/*}/include/common.bash"
. "${BASH_SOURCE%/*}/include/cli.bash"

# Main command help
# Arguments:
#  1 - Prefix for subcommand help execution
#
# Environment
#  -
#
# Out:
#  Proper help
#
# Exit status:
#  Always 0
kafka_help () {
    cat <<-EOF
		WCS kafka configuration tool.

		Please use some of the following commands:
	EOF

    zz_cli_subcommand_help "$1"
}

# Main cli entrypoint
main () {
    declare wcs_kafka_cli_prefix
    wcs_kafka_cli_prefix="${PREFIX}/share/wcs/cli/wcs-kafka-"
    declare -r wcs_kafka_cli_prefix

    if [[ $# == 0 || $1 == --help ]]; then
        kafka_help "$wcs_kafka_cli_prefix"
        exit 0
    elif [[ $1 == --shorthelp ]]; then
        printf '%s\n' 'Handle or ask wcs kafka cluster'
        exit 0
    fi


    zz_cli_case "${wcs_kafka_cli_prefix}" "$@"
}

main "$@"
