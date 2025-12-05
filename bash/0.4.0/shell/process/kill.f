shell.process.kill() {
  # description

  # argument variables
  local _process=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _json_processes="{}"
  local _tag=shell.process.kill

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
      -p | --process )
        shift
        _process="${1}"
      ;;
    esac
    shift
  done

  # main
  if [[ ! -z ${_process} ]]; then
    # get all running processes for ${_process}
    _json_processes=$( ${cmd_osqueryi} "select pid from processes where name=='${_process}' and parent==1" --json )
  
    # start/restart mod_gearman_worker
    if  [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) == 0 ]] ||
        [[ $( ${cmd_echo} ${_json_processes} | ${cmd_jq} '. | length' ) -gt 1 ]]; then
      
      # kill all
      for pid in $( ${cmd_echo} ${_json_processes} | ${cmd_jq} -r '.[]' ); do
        if ${cmd_kill} -s ${pid}; then
          shell.log --screen --message "stopping ${_process}(${pid}) successful" --tag ${_tag} --remote-server ${LOG_SERVER}
        else
          shell.log --screen --message "stopping ${_process}(${pid}) failed" --tag ${_tag} --remote-server ${LOG_SERVER}
          (( _error_count++ ))
        fi
      done
    fi
  fi

  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}