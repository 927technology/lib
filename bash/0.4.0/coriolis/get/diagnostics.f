coriolis.get.diagnostics() {
  # edited
  # chris murray
  # 202601122

  # description

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
  # set credentials
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  [[ -z ${_profile} ]] && { shell.log "${FUNCNAME}(${_profile}) - [PROFILE] Profile is not set.   Set profile move.set.profile --name <profile name>"; return ${exit_crit}; }

  # check if coriolis is available
  if ${cmd_ping} -c1 coriolis >/dev/null 2>&1; then
    shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] Ping"
    

  else
    shell.log "${FUNCNAME}(${_profile}) - [FAILURE] Ping"
  
  fi

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}