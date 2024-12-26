# Copyright (c) Bruno Sales <me@baliestri.dev>. Licensed under the MIT License.
# See the LICENSE file in the project root for full license information.

#!/usr/bin/env zsh

function __gitprofiles_hook() {
  ## Check if git is installed
  if (( ! $+commands[git] )); then
    return 1
  fi

  local -A profile_path_map=()
  local -A profile_cfg_map=()

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

  ## Iterate over all profiles to get the name, email, signingkey and path
  for profile in ${profiles}; do
    local -A profile_value_map=()

    while read -r key value; do
      case "${key}" in
        name)
          profile_value_map[name]="${value}"
          ;;
        email)
          profile_value_map[email]="${value}"
          ;;
        signingkey)
          profile_value_map[signingkey]="${value}"
          ;;
        path)
          profile_value_map[path]="${value}"
          ;;
      esac
    done < <(awk -F ' = ' '/^\[profile/{p=0} /^\[profile "[^"]*'"${profile}"'"/{p=1} p {gsub(/"/, "", $2); print $1,$2}' ${profile_filepath})

    profile_path_map[${profile}]="${profile_value_map[path]}"

    profile_cfg_map[${profile}.name]="${profile_value_map[name]}"
    profile_cfg_map[${profile}.email]="${profile_value_map[email]}"

    if [[ -n "${profile[signingkey]}" ]]; then
      profile_cfg_map[${profile}.signingkey]="${profile_value_map[signingkey]}"
    fi
  done

  ## Get the current directory
  local -A current=()
  current[dir]=$(pwd)

  ## Check if the current directory is in one of the profiles paths
  for profile in ${(k)profile_path_map}; do
    if [[ "${current[dir]}" =~ "${profile_path_map[${profile}]}" ]]; then
      local current[profile]="${profile}"
      break
    fi
  done

  ## If the current directory is not in any profile path, use the default profile
  if [[ -z "${current[profile]}" ]]; then
    local current[profile]="default"
  fi

  ## Set the current profile name and email
  git config --global user.name "${profile_cfg_map[${current[profile]}.name]}"
  git config --global user.email "${profile_cfg_map[${current[profile]}.email]}"

  ## Set the current profile signingkey if it exists
  if [[ -n "${profile_cfg_map[${current[profile]}.signingkey]}" ]]; then
    git config --global user.signingkey "${profile_cfg_map[${current[profile]}.signingkey]}"
  fi
}

add-zsh-hook chpwd __gitprofiles_hook
