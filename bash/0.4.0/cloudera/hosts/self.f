cloudera.hosts.self() {
  # description

  # variables
  local _api_version=v19
  local _hostname=$( ${cmd_hostname} -f )
  local _json=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  # none

  # parse arguments
  # none

  # main
  _json=$( cloudera.api --api /hosts/${_hostname} ${@} )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}