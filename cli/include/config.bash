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

# Reads user input, using readline completions interface to fill paths.
# Arguments:
#  $1 - Variable to store user introduced text
#  $2 - Prompt to user
#  $3 - Default answer (optional)
zz_read_path () {
    read -e -i "$3" -r -p "$2: " "$1"
}

# Reads user input, forbidding tab (or other keys) completions but enabling
# the rest of readline features, like navigate through arrow keys
# Arguments:
#  $1 - Variable to store user introduced text
#  $2 - Prompt to user
#  $3 - Default answer (optional)
zz_read () {
    read -r "$1" < <(
        # Process substitution avoids overriding complete un-binding. Another
        # way, exiting with Ctrol-C would cause binding ruined.
        bind -u 'complete' 2>/dev/null
        zz_read_path "$1" "$2" "$3" >/dev/tty
        printf '%s' "${!1}"
    )
}

# ZZ variables treatment. Checks if an environment variable is defined, and ask
# user for value if not.
# After that, save it in docker-compose .env file
# Arguments:
#  $1 The variable name. Will be overridden if needed.
#  $2 Default value if empty text introduced ("" for error raising)
#  $3 Question text
#  $4 env file to write
# Environment:
#  env_vars - Associated array to update.
#
# Out:
#  User Interface
#
# Exit status:
#  Always 0
zz_variable () {
  declare -r env_file="$4"

  if [[ "$1" == PREFIX || "$1" == *_PATH ]]; then
    declare -r read_callback=zz_read_path
  else
    declare -r read_callback=zz_read
  fi

  while [[ -z "${!1}" ]]; do
    "$read_callback" "$1" "$3" "$2"

    if [[ -z "${!1}" && -z "$2" ]]; then
      log fail "[${!1}][$2] Empty $1 not allowed"$'\n'
    fi
  done

  if [[ $1 != PREFIX ]]; then
    printf '%s=%s\n' "$1" "${!1}" >> "$env_file"
  fi
}

# Print a warning saying that "$src_env_file" has not been modified.
# Arguments:
#  -
#
# Environment:
#  src_env_file - Original file to print in warning. It will print no message if
#  it does not exist or if it is under /dev/fd/.
#
# Out:
#  -
#
# Exit status:
#  Always 0
print_not_modified_warning () {
    echo
    if [[ "$src_env_file" != '/dev/fd/'* && -f "$src_env_file" ]]; then
        log warn "No changes made to $src_env_file"$'\n'
    fi
}

# Ask user for a single ZZ variable. If the environment variable is defined,
# assign the value to the variable directly.
# Arguments:
#  $1 The env file to save variables
#  $2 The variable to ask user for
#
# Environment:
#  env_vars - The associated array to update.
#
# Out:
#  User Interface
#
# Exit status:
#  Always 0
zz_variable_ask () {
    local var_default var_prompt

    IFS='|' read -r var_default var_prompt < \
                                        <(squash_spaces <<<"${env_vars[$2]}")

    zz_variable "$2" "$var_default" "$var_prompt" "$1"
}

# Set variable in env file
# Arguments:
#  1 - File from get variables
#  2 - Variable to set
#  3 - Value to set
# Environment:
#  -
#
# Out:
#  -
#
# Exit status:
#  0 - Variable is set without error
#  1 - An error has ocurred while set a variable (variable not found or mispelled)
zz_set_var () {
    declare -r env_file="$1"
    declare -r key="$2"
    declare -r value="$3"

    printf -v new_value "%s=%s" "$key" "$value"
    sed -i "/^$key.*/c$new_value" "$env_file"
}
