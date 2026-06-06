libnss.cleanup() {
  # edited
  # chris murray
  # 20260311

  # description
  # 

  # local variables
  # none 
  
  # argument variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  shell.log "${FUNCNAME}(${_profile}) - [DELETING] File:  ${NSS_WRAPPER_HOSTS}"

  if [[ ! -z LD_PRELOAD ]]; then
    unset LD_PRELOAD || (( _error_count++ ))
  
  fi

  if  [[ ! -z ${NSS_WRAPPER_HOSTS} ]] &&
      [[ -f ${NSS_WRAPPER_HOSTS} ]]; then
    ${cmd_rm} --force ${NSS_WRAPPER_HOSTS} || (( _error_count++ ))
    unset NSS_WRAPPER_HOSTS || (( _error_count++ ))

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}