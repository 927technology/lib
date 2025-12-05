927.ops.start.jobworker() {
  # description
  # 

  # dependancies
  # variables.l
  # shell_process.l

  # argument variables
  local _json="{}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _restart=${false}

  # local variables
  local _json_processes=$( ${cmd_osqueryi} "select pid from processes where name=='mod_gearman_wor' and parent==1" --json )
  local _path_modgearman=/etc/mod_gearman
  local _tag=927.ops.start.jobworker

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
  if  [[ -d ${_path_modgearman} ]]; then
    shell.log --screen --message "CREATE: ${_path_modgearman} EXISTS" --tag ${_tag} --remote-server ${LOG_SERVER}

    # create ${_path_modgearman}/worker.conf
    927.mod_gearman.create.worker || (( _error_count++ ))

    # create secrets path ${_path_modgearman}/secrets
    shell.create.directory --directory ${_path_modgearman}/secrets --group naemon --mode 500 --owner naemon || (( _error_count++ ))

    # crate ${_path_modgearman}/secrets/worker.pwd
    if shell.create.file --group naemon --owner naemon --mode 600 --path ${_path_modgearman}/secrets/worker.pwd; then 

      # write ${_path_modgearman}/secrets/worker.pwd
      if [[ $( ${cmd_echo} "${_json_secrets}" | "${cmd_jq}" -r '. | select( .key == "pass_service-account_jobworker" ).value' | to_sha256 ) == $( ${cmd_echo} ${_path_modgearman}/secrets/worker.pwd | to_sha256 ) ]]; then
        shell.log --screen --message "VALIDATE: worker password SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
        
      else
        shell.log --screen --message "VALIDATE worker password FAILED" --tag ${_tag} --remote-server ${LOG_SERVER}
        ${cmd_echo} "${_json_secrets}" | "${cmd_jq}" -r '. | select( .key == "pass_service-account_jobworker" ).value' > ${_path_modgearman}/secrets/worker.pwd
        _restart=${true}
      
      fi
    
    fi

    # create pid file
    shell.create.file --group naemon  --mode 600 --owner naemon --path /run/mod-gearman-worker.pid || (( _error_count++ ))

    # restart
    if  [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) > 0 ]] && \
        [[ ${_restart} == ${true} ]]; then
      
      # restart mod_gearman_worker
      for pid in $( ${cmd_echo} ${_json_processes} | ${cmd_jq} -r '.[].pid' ); do
        
        # hup existing service
        if ${cmd_kill} -HUP ${pid}; then
          shell.log --screen --message "RESTARTING: mod_gearman_worker\(${pid}\) successful" --tag ${_tag} --remote-server ${LOG_SERVER}
        
        else
          shell.log --screen --message "RESTARTING: mod_gearman_worker \(${pid}\) failed" --tag ${_tag} --remote-server ${LOG_SERVER}
          (( _error_count++ ))
        
        fi
      done

    elif [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) == 0 ]]; then
      
      # start mod_gearman_worker
      if ${cmd_su} naemon --shell=/bin/bash --preserve-environment "--command=${cmd_mod_gearman_worker} --daemon --config=${_path_modgearman}/worker.conf --pidfile=/run/mod-gearman-worker.pid"; then
        shell.log --screen --message "STARTING: mod_gearman_worker successful" --tag ${_tag} --remote-server ${LOG_SERVER}
      
      else
        shell.log --screen --message "STARTING: mod_gearman_worker failed" --tag ${_tag} --remote-server ${LOG_SERVER}
        (( _error_count++ ))
      
      fi
    
    else 
      shell.log --screen --message "STARTED: mod_gearman_worker" --tag ${_tag} --remote-server ${LOG_SERVER}

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