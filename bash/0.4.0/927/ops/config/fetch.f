927.ops.config.fetch() {
  # description
  # pulls ops configuration from remote source
  # accepts 0 arguments
  
  # dependancies
  # 927/ops/create/commands.f
  # 927/ops/create/contactgroups.f
  # 927/ops/create/contacts.f
  # 927/ops/create/hostgroups.f
  # 927/ops/create/hosts.f
  # 927/ops/create/jobserver.f
  # 927/ops/create/servicegroups.f
  # 927/ops/create/services.f
  # 927/ops/create/servicedependencies.f
  # 927/ops/create/serviceescalations.f
  # 927/ops/create/timeperiods.f
  # json/validate.f
  # shell/log.f
  # time/epoch.f
  # variables/bools.v
  # variables/cmd_<platform>.v
  # variables/exits.v

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  
  # variables
  local _configurations=configuration,infrastructure
  local _config_candidate=
  local _config_running=
  local _json="{}"
  local _path_naemon=/etc/naemon
  local _path_927=/etc/927
  local _tag=927.ops.config.fetch
  local _timestamp=$( date.epoch )
  
  # parse command arguments
  # none

  # main
  # make output path
  ${cmd_mkdir} --parents ${_path_927}${_path_naemon}/${_timestamp} || (( _error_count++ ))

  # loop for configurations pulled
  for configuration in $( ${cmd_echo} ${_configurations} | ${cmd_sed} 's/,/\n/g' ); do
    shell.log --message "fetching ${URL}/${configuration}.json" --tag ${_tag} --remote-server ${LOG_SERVER}

    # zero out loop variables
    _json=
   
    # get remote configuration
    _json=$( ${cmd_curl} --silent ${URL}/${configuration}.json | ${cmd_jq} -c )
    
    if json.validate --json ${_json}; then
      # write json to file
      shell.log --message "writing ${_path_927}${_path_naemon}/${_timestamp}/${configuration}.json" --tag ${_tag} --remote-server ${LOG_SERVER}
      ${cmd_echo} ${_json} > ${_path_927}${_path_naemon}/${_timestamp}/${configuration}.json

      # set exit code
      [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

    else
      # set exit code
      _exit_code=${exit_crit}
    fi
  done

  # link candidate if no errors were generated
  if [[ ${_error_count} == 0 ]]; then
    # mark timestamp as current candidate
    shell.log --message "linking candidate ${_path_927}${_path_naemon}/${_timestamp}" --tag ${_tag} --remote-server ${LOG_SERVER}
    
    # unlink candidate if present
    [[ -L ${_path_927}${_path_naemon}/candidate ]] && ${cmd_unlink} ${_path_927}${_path_naemon}/candidate
    
    # link new candidate
    ${cmd_ln} --force --symbolic ${_path_927}${_path_naemon}/${_timestamp} ${_path_927}${_path_naemon}/candidate
  fi  

  # clean up unnecessary candidates
  [[ -L ${_path_927}${_path_naemon}/candidate ]] && _link_candidate=$( ${cmd_readlink} ${_path_927}${_path_naemon}/candidate | ${cmd_awk} -F"/" '{print $NF}' )
  [[ -L ${_path_927}${_path_naemon}/running ]] && _link_running=$( ${cmd_readlink} ${_path_927}${_path_naemon}/running | ${cmd_awk} -F"/" '{print $NF}' )

  for candidate in $( ${cmd_ls} ${_path_927}${_path_naemon} | ${cmd_grep} --word-regexp ^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9] ); do 
    if [[ ${candidate} != ${_link_candidate} ]] && [[ ${candidate} != ${_link_running} ]]; then
      shell.log --message "deleting candidate ${_path_927}${_path_naemon}/${candidate}" --tag ${_tag} --remote-server ${LOG_SERVER}
      ${cmd_rm} -rf ${_path_927}${_path_naemon}/${candidate}
    fi
  done

  # exit
  return ${_exit_code}
}