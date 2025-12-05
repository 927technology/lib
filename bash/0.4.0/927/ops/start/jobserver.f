927.ops.start.jobserver() {
  # description
  # 

  # dependancies
  # variables.l
  # shell_process.l

  # argument variables
  local _json="{}"
  local _json_secrets="{}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _restart=${false}

  # local variables
  local _command_gearmand="${cmd_gearmand} --daemon --log-file none --syslog $OPTIONS"
  local _json_processes=$( ${cmd_osqueryi} "select pid from processes where name=='gearmand' and parent==1" --json )
  local _path_gearmand=/etc/mod_gearman
  local _tag=927.ops.start.jobserver

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -s | --secrets )
        shift
        _json_secrets="${1}"
      ;;
    esac
    shift
  done  

  # main
  if  [[ -d ${_path_gearmand} ]]; then
    shell.log --screen --message "path ${_path_gearmand} exists" --tag ${_tag} --remote-server ${LOG_SERVER}

    # create /etc/mod_gearman/module.conf
    if 927.ops.create.mod_gearman-module --json ${_json_secrets}; then
      shell.log --screen --message "gearman module.conf created successfully" --tag ${_tag} --remote-server ${LOG_SERVER}
    else
      shell.log --screen --message "gearman module.conf creation failed" --tag ${_tag} --remote-server ${LOG_SERVER}
      (( _error_count++ ))
    fi

    # create secrets path
    if shell.create.directory --directory ${_path_gearmand}/secrets --group gearmand --mode 500 --owner gearmand; then
 
      # crate ${_path_gearmand}/secrets/module.pwd
      if shell.create.file --group gearmand --owner gearmand --path ${_path_gearmand}/secrets/module.pwd; then

        # write ~gearmand/secrets/module.pwd
        if [[ $( ${cmd_echo} "${_json_secrets}" | "${cmd_jq}" -r '. | select( .key == "pass_service-account_jobserver" ).value' | to_sha256 ) == $( ${cmd_echo} ~gearmand/secrets/module.pwd | to_sha256 ) ]]; then
          shell.log --screen --message "candidate module password matches" --tag ${_tag} --remote-server ${LOG_SERVER}
          
        else
          shell.log --screen --message "candidate module password does not match" --tag ${_tag} --remote-server ${LOG_SERVER}
          ${cmd_echo} "${_json_secrets}" | "${cmd_jq}" -r '. | select( .key == "pass_service-account_jobserver" ).value' > ~gearmand/secrets/module.pwd
          _restart=${true}
        fi
      fi
    fi

  # start/restart gearmand
  if  [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) == 0 ]] ||
      [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) -gt 1 ]]; then
    
    # kill gearmand
    shell.process.kill --process gearmand
    
    # start gearmand
    shell.process.start --command "${_mod_gearman_command}" --preserve-environment --std-err /dev/null --std-out /dev/null --user gearmand || (( _error_count++ ))
 
  else
    # restart
    shell.process.restart --process gearmand
  fi

  else
    shell.log --screen --message "path ${_path_gearmand} does not exists" --tag ${_tag} --remote-server ${LOG_SERVER}
    (( _error_count++ ))
  fi

  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}