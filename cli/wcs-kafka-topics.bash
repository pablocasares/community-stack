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

# Main kafka subcommands entrypoint
# Arguments:
#  [--shorthelp] - Show one line help
#  [-h/--help] - Show help
#
# Environment
#  - PREFIX: The Wizzie community stack installation location
#
# Out:
#  The help or subcommand output
#
# Exit status:
#  The Subcommand exit status

. "${BASH_SOURCE%/*}/include/common.bash"
. "${BASH_SOURCE%/*}/include/cli.bash"

# Print kafka argument list in a user-friendly way. Use stdin to provide Kafka
# argument.
#
# Arguments
#  -
#
# Environment
#  -
#
# Out
#  UX message
#
ux_err_print_help_options () {
    declare -r -a omit_parameters_arr=(
        zookeeper broker-list bootstrap-server new-consumer)

    declare omit_parameters
    omit_parameters=$(str_join '|' "${omit_parameters_arr[@]}")
    declare -r omit_parameters

    #shellcheck disable=SC2016
    # In the next string we want bash to not expand $0, but awk
    declare -r print_headers_awk='NR==2 {RS="\n--"} NR<=3 {print $0; next}'
    # Set this record separator   ^^^^^^^^^^^^^^^^^^^
    # only after the 3rd line
    # Skip help and table header                       ^^^^^^^^^^^^^^^^^^^^^^^

    #shellcheck disable=SC2016
    # In the next string we want bash to not expand $0, but awk
    declare -r print_arguments_awk="!/^(${omit_parameters})/"' {print "--"$0}'
    # Filter out the unwanted help    ^^^^^^^^^^^^^^
    # parameters

    awk "${print_headers_awk} ${print_arguments_awk}"
}

# Print kafka exception in an user friendly way. Use stdin to provide Kafka
# exception.
#
# Arguments
#  1 - kafka*.sh out file
#
# Environment
#  -
#
# Out
#  UX message
#
ux_err_print_java_exception () {
    grep 'Exception in thread\|Caused by' | cut -d ':' -f 2-
}

# Filter complicated kafka output and filter-out connection hidden stuff
# Arguments
#  -
# Environment
#  -
#
# Out
#  UX message
ux_err_print () {
    declare first_line print_callback

    # Skip docker-compose errors
    while IFS= read -r first_line; do
        if [[ "$first_line" == \
                     'The '*' variable is not set. Defaulting to '* ]]; then
                            printf '%s' "$first_line"
            else
                break
        fi
    done

    if [[ -z "$first_line" ]]; then
        # stdin SIGPIPE, or very strange empty line. Continue will cause a
        # spurious newline printed
        return 0
    fi

    case "$first_line" in
        'Command must include exactly one action:'*| \
        'Exactly one of whitelist/topic is required.'*| \
        'Missing required argument'*| \
        *'is not a recognized option'*)
            print_callback=ux_err_print_help_options
            ;;
        'Exception in thread'*)
            print_callback=ux_err_print_java_exception
            ;;
        *)
            # Last resort
            print_callback='cat'
            ;;
    esac

    cat <(printf '%s\n' "$first_line") - | "$print_callback"
}

# Execute the given kafka container script located in /opt/kafka/.sh script
# located in the container, forwarding all arguments and adding proper options
# if needed.
# Arguments
#  1 - The container command to execute
#  N - The container binary arguments
#
# Environment
#  cmd_default_parameters - Use this parameters if they are not found in the cmd
#  line.
#
# Out
#  UX message
#
# Note
#  Running in a subshell to achieve pipefail locality
container_kafka_exec () (
    set -o pipefail
    declare -a wcs_params
    declare -r container_bin="$1"
    shift

    for arg in "${!cmd_default_parameters[@]}"; do
        wcs_params+=("$arg")
        wcs_params+=("${cmd_default_parameters[$arg]}")
    done

    "${PREFIX}/bin/wcs" compose exec -T kafka \
            "/opt/kafka/bin/${container_bin}" "${wcs_params[@]}" "$@" \
            2> >(ux_err_print >&2)
)

# Prepare kafka container command server parameter.
# Arguments
#  1 - The parameter that uses the command to identify server
#  2 - The port of the parameter value
#  N - Provided binary arguments
#
# Environment
#  cmd_default_parameters - The associative array that will be filled with
#  server parameter
#
# Out
#  -
#
prepare_cmd_default_server () {
    declare server_host
    declare -r server_parameter="$1"
    shift 1

    if ! array_contains "${server_parameter}" "$@"; then
        if [[ "${server_parameter}" == --zookeeper ]]; then
            server_host=zookeeper:2181
        else
            server_host="$(. "${PREFIX}/etc/wcs/.env"; echo "$INTERFACE_IP"):9092"
        fi
        cmd_default_parameters["$server_parameter"]="${server_host}"
    fi
}

# Main kafka subcommands entrypoint
main () {
    if [[ "$1" == '--shorthelp' ]]; then
        printf '%s\n' 'Handle or ask kafka cluster'
        exit 0
    fi

    declare -g -A cmd_default_parameters

    declare my_name container_bin server_parameter
    my_name=$(basename -s '.bash' "$0")
    declare -r my_tail="${my_name##*-}"

    # See https://github.com/koalaman/shellcheck/issues/1044
    #shellcheck disable=SC2221
    #shellcheck disable=SC2222
    case "${my_tail}" in
    topics)
        container_bin='kafka-topics.sh'
        server_parameter='--zookeeper'
        ;;
    produce|consume)
        if [[ $# -gt 0 && "$1" != "--"* ]]; then
            # The first argument is topic
            cmd_default_parameters['--topic']="$1"
            shift
        fi
        ;;&
    produce)
        container_bin='kafka-console-producer.sh'
        server_parameter='--broker-list'
        ;;
    consume)
        container_bin='kafka-console-consumer.sh'

        if array_contains '--zookeeper' "$@"; then
            server_parameter='--zookeeper'
        else
            server_parameter='--bootstrap-server'
        fi

        if [[ $# -gt 0 && "$1" != "--"* ]]; then
            # The second argument is partition
            cmd_default_parameters['--partition']="$1"
            shift
        fi
        ;;
    *)
        log error "Unknown subcommand ${my_tail}.\\n"
        exit 1
    esac

    prepare_cmd_default_server "${server_parameter}"
    container_kafka_exec "${container_bin}" "$@"
}

main "$@"
