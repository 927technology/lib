927.ops.config.compare() {
  # description
  # checks candidate configuration to running and promotes if 
  # there is a change
  # accepts 0 arguments
  # only returns exit code, no output
  
  # dependancies
  # hash/sum/sha256.v
  # shell/log.f
  # variables/bools.v
  # variables/cmd_<platform>.v
  # variables/exits.v

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  
  # variables
  local _configurations=configuration,infrastructure
  local _json="{}"
  local _path_naemon=/etc/naemon
  local _path_927=/etc/927
  local _tag=927.ops.config.compare
  local _hash_candidate
  local _hash_running

  # parse command arguments
  # none

  # main
  # loop for configurations pulled
  for configuration in $( ${cmd_echo} ${_configurations} | ${cmd_sed} 's/,/\n/g' ); do
    shell.log --message "comparing ${configuration}.json " --tag ${_tag} --remote-server ${LOG_SERVER}

    # zero out loop variables
    _json=

    # make output path
    [[ ! -d ${_path_927}${_path_naemon}/candidate ]] && ${cmd_mkdir} -p ${_path_927}${_path_naemon}/candidate || (( _err_count++ ))
    # [[ ! -d ${_path_927}${_path_naemon}/running ]]   && ${cmd_mkdir} -p ${_path_927}${_path_naemon}/running   || (( _err_count++ ))

    # get file hashes
    shell.log --message "comparing candidate to running configs" --tag ${_tag} --remote-server ${LOG_SERVER}
    [[ -f  ${_path_927}${_path_naemon}/candidate/${configuration}.json ]]  && _hash_candidate=$( ${cmd_echo} ${_path_927}${_path_naemon}/candidate/${configuration}.json | to_sha256 ) || (( _err_count++ ))
    [[ -f  ${_path_927}${_path_naemon}/running/${configuration}.json ]]    && _hash_running=$( ${cmd_echo} ${_path_927}${_path_naemon}/running/${configuration}.json     | to_sha256 ) || (( _err_count++ ))

    if [[ ${_hash_candidate} == ${_hash_running} ]]; then

      # success
      shell.log --message "candidate and running configs match" --tag ${_tag} --remote-server ${LOG_SERVER}

      # set exit code
      [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

    else
      shell.log --message "candidate and running configs do not match " --tag ${_tag} --remote-server ${LOG_SERVER}

      # set exit code
      [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_warn}

    fi
  done

  # exit
  return ${_exit_code}
}