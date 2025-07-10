docker.ps () {
  # description
  # outputs running docker instances on host as json
  # accepts 0 arguments

  # local variables
  local _count=0
  local _json="{}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  _json=$( ${cmd_docker} ps --all --format='{{json .}}' | ${cmd_jq} -sc )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}