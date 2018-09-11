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

# We are located in ${PREFIX}/share/wcs/cli/wcs.bash

# Resolve symlinks
my_path=$(realpath "${BASH_SOURCE[0]}")
declare -r my_path
# Extract wcs prefix
declare -r PREFIX=${my_path%/share/wcs/cli/wcs.bash}

# Include common functions
. "${PREFIX}/share/wcs/cli/include/common.bash"
. "${PREFIX}/share/wcs/cli/include/cli.bash"

# Wizzie Community Stack cli help
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
main_help () {
    cat <<-EOF
		Welcome to Wizzie Community Stack CLI interface!

		Please use some of the next options to start using wcs:
	EOF

    zz_cli_subcommand_help "$1"
}

# Main cli entrypoint
# Arguments:
#  [-h/--help] - Show help
#
# Environment
#  - PREFIX: Wizzie community stack installation location
#
# Out:
#  Help or subcommand output
#
# Exit status:
#  Subcommand exit status
main () {
    if [[ "$1" == '--version' || $1 == '-v' ]]; then
        printf "Wizzie Community Stack - The lightweight Wizzie Data Platform (WDP)"
        exit 0
    fi

    declare -r wcs_cli_prefix="${PREFIX}/share/wcs/cli/wcs-"

    if [[ $# == 0 || $1 == '-h' || $1 == '--help' ]]; then
        main_help "${wcs_cli_prefix}"
        exit 0
    fi

    zz_cli_case "${wcs_cli_prefix}" "$@"
}

main "$@"
