# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

# vim: set ts=4 sw=4 tw=0 et :
#!/usr/bin/env zsh

function __gitprofiles_hook() {
  ## Check if git is installed
  if (( ! $+commands[git] )); then
    return 1
  fi

  typeset -A profile_paths_map
  typeset -A profile_cfg_map

  ## Get the path to the profile file
  zstyle -s ":empresslabs:git:profile" path profile_filepath

  ## Check if the file exists
  if [[ ! -f "${profile_filepath}" ]]; then
    return 1
  fi

  ## Load all stored profiles
  local profiles=($(grep -o '\[profile [^]]*\]' ${profile_filepath} | tr -d '[]" ' | sed 's/profile//g' | tr '\n' ' '))

  ## Check if default profile exists
  if [[ ! "${profiles}" =~ "default" ]]; then
    echo "gitprofiles: 'default' profile not found in '${profile_filepath}'"
    return 1
  fi

  # Ensure glob patterns that don't match don't cause errors
  setopt LOCAL_OPTIONS NO_NOMATCH

  # Function to parse paths into an array and support tidle expansion
  function __parse_paths() {
    local raw_paths="${(j:\n:)@}"              # join args with newlines
    local temp=(${(s:,:)raw_paths})           # split on commas first
    # Now split each part by newlines
    local paths=()
    for part in $temp; do
      paths+=(${(f)part})                     # split on newlines
    done

    # Process each path
    paths=(${paths##[[:space:]]})             # Trim leading spaces
    paths=(${paths%%[[:space:]]})             # Trim trailing spaces
    paths=(${~paths})                         # Expand tilde
    paths=(${paths:#})                        # Remove empty elements

    echo ${paths}
}

  ## Iterate over all profiles to get the name, email, signingkey and path
  for profile in ${profiles}; do
    typeset -A profile_value_map

    while read -r key value; do
      case "${key}" in
        name|email|signingkey)
          profile_value_map[${key}]="${value}"
          ;;
        path|paths)
          profile_value_map[paths]="${value}"
          ;;
      esac
    done < <(awk -F ' = ' '/^\[profile/{p=0} /^\[profile "[^"]*'"${profile}"'"/{p=1} p {gsub(/"/, "", $2); print $1,$2}' ${profile_filepath})

    # Parse paths
    if [[ -n "${profile_value_map[paths]}" ]]; then
      profile_paths_map[${profile}]="$(__parse_paths "${profile_value_map[paths]}")"
    fi

    profile_cfg_map[${profile}.name]="${profile_value_map[name]}"
    profile_cfg_map[${profile}.email]="${profile_value_map[email]}"

    if [[ -n "${profile[signingkey]}" ]]; then
      profile_cfg_map[${profile}.signingkey]="${profile_value_map[signingkey]}"
    fi
  done

  # Get current directory
  local current_dir=$(pwd)
  local matched_profile="default"

  [[ -n "${DEBUG}" ]] && echo "Current directory: ${current_dir}"

  # Check if current directory matches any profile paths
  for profile in ${(k)profile_paths_map}; do
    [[ -n "${DEBUG}" ]] && echo "Testing Profile: ${profile}"

    local paths=(${=profile_paths_map[${profile}]})  # Convert to array

    for path_pattern in $paths; do
      [[ -n "${DEBUG}" ]] && echo "Checking path pattern: ${path_pattern}"

      if [[ "${current_dir}" =~ "${path_pattern}" ]]; then
        matched_profile="${profile}"
        break 2
      fi
    done
  done

  ## Set the current profile name and email
  git config --global user.name "${profile_cfg_map[${matched_profile}.name]}"
  git config --global user.email "${profile_cfg_map[${matched_profile}.email]}"

  ## Set the current profile signingkey if it exists
  if [[ -n "${profile_cfg_map[${matched_profile}.signingkey]}" ]]; then
    git config --global user.signingkey "${profile_cfg_map[${matched_profile}.signingkey]}"
  fi

  # Print debug information if DEBUG is set
  if [[ -n "${DEBUG}" ]]; then
    echo "Matched profile: ${matched_profile}"
    echo "Using configuration:"
    echo "  name: ${profile_cfg_map[${matched_profile}.name]}"
    echo "  email: ${profile_cfg_map[${matched_profile}.email]}"
    if [[ -n "${profile_cfg_map[${matched_profile}.signingkey]}" ]]; then
      echo "  signingkey: ${profile_cfg_map[${matched_profile}.signingkey]}"
    fi
  fi
}


add-zsh-hook chpwd __gitprofiles_hook
