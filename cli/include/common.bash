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

readonly DEFAULT_PREFIX='/usr/local'

# log function
log () {
    # Text colors definition
    declare -r red=$'\e[1;31m'
    declare -r green=$'\e[1;32m'
    declare -r yellow=$'\e[1;33m'
    declare -r white=$'\e[1;37m'
    declare -r normal=$'\e[m'

    case $1 in
        e|error|erro) # ERROR
            printf '[ %sERRO%s ] %s' "${red}" "${normal}" "$2"
        ;;
        i|info) # INFORMATION
            printf '[ %sINFO%s ] %s' "${white}" "${normal}" "$2"
        ;;
        w|warn) # WARNING
            printf '[ %sWARN%s ] %s' "${yellow}" "${normal}" "$2"
        ;;
        f|fail) # FAIL
            printf '[ %sFAIL%s ] %s' "${red}" "${normal}" "$2"
        ;;
        o|ok) # OK
            printf '[  %sOK%s  ] %s' "${green}" "${normal}" "$2"
        ;;
        *) # USAGE
            printf 'Usage: log [i|e|w|f] <message>'
        ;;
    esac
}

# Check if command exists
#
# @param      Command to check
#
# @return     True if command exists, else false.
#
command_exists () {
    command -v "$1" 2>/dev/null
}

# Read a y/n response and returns true if answer is yes.
#
# @param      [--help] Help text describing what the user is answering (in next
#             parameter)
# @param      Prompt text
#
# @return     True if answer is yes, else false.
#
read_yn_response () {
    declare reply help_text='' possible_answers='Y/n'
    if [[ $# -gt 1 && $1 == '--help' ]]; then
        possible_answers='Y/n/h'
        help_text="$2"
        shift 2
    fi

    while true; do
        read -p "$1 [$possible_answers]: " -n 1 -r reply
        if [[ ! -z $help_text && ( $reply == 'h' || $reply == 'H' ) ]]; then
            printf '\n%s\n' "$help_text"
        else
            break
        fi
    done

    if [[ ! -z $reply ]]; then
        printf '\n'
    fi

    [[ -z $reply || $reply == 'y' || $reply == 'Y' ]]
}

# Creates a temporary unnamed file descriptor that you can use and it will be
# deleted at shell exit (on close). File descriptor will be saved in $1 variable
# Arguments:
#  1 - Variable to save newly created temp file descriptor
tmp_fd () {
    declare file_name
    file_name=$(mktemp)
    declare -r file_name
    eval "exec {$1}>${file_name}"
    rm "${file_name}"
}

# Check if an array contains a particular element
#
# Arguments:
#  1 - Element to find
#  N - Array passed as "${arr[@]}"
#
# Out:
#  None
#
# Return:
#  True if found, false other way
array_contains () {
    declare -r needle="$1"
    shift

    for element in "$@"; do
        if [[ "${needle}" == "${element}" ]]; then
            return 0
        fi
    done

    return 1
}

# Print a string which is the concatenation of the strings in parameters >1. The
# separator between elements is $1.
#
# Arguments
#  1 - The Token to use to join (can be empty, '')
#  N - The strings to join
#
# Environment
#  -
#
# Out:
#  Joined string
#
# Return code
#  Always 0
str_join () {
    declare ret
    declare -r join_str="$1"
    shift

    while [[ $# -gt 0 ]]; do
        ret+="$1"
        if [[ $# -gt 1 ]]; then
            ret+="$join_str"
        fi

        shift
    done

    printf '%s\n' "$ret"
}

##
## @brief      Squeeze contiguous blanks and delete escaped ones from stdin
##
## @return     Squeezed string via stdout
##
squash_spaces () {
    declare -r squash='s/\\\?[[:space:]]\+/ /g'
    declare -r trim_end='s/[[:space:]]\+$//'
    declare -r trim_beg='s/^[[:space:]]\+//'
    sed -z "$squash;$trim_end;$trim_beg"
}

# Fallback cp in case that file is deleted.
# On some systems, copy the temporary file descriptor created by temp_fd will
# give a 'Stale file handle'. This wrapper will fallback to a file copy if that
# is needed
cp () {
    declare opt_index src_file='' dst_file dash_options=y
    # Extract first file name
    for ((opt_index=1;opt_index<=$#;opt_index++)); do

        # Find source file option index
        if [[ "$dash_options" == 'y' && "${!opt_index}" == '-'* ]]; then
            if [[ "${!opt_index}" == '--' ]]; then
                # Beyond this point, only files are allowed
                dash_options=n
            fi

            continue # This option did not contain src or dest files
        fi

        if [[ -z "$src_file" ]]; then
            src_file="${!opt_index}"
        else
            dst_file="${!opt_index}"
            break
        fi
    done


    # If source file is deleted, fallback to dd
    if [[ -L "${src_file}" ]] && \
                        ! realpath -e "${src_file}" >/dev/null 2>&1; then
        dd status='none' if="${src_file}" of="${dst_file}" 2>/dev/null

    else
        /usr/bin/env cp "$@"
    fi
}
