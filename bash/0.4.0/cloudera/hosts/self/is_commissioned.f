cloudera.hosts.self.is_commissioned() {
  # description

  # variables
  local _api_version=v19

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  # none

  # parse arguments
  # none

  # main
  _exit_string=$( cloudera.hosts.self ${@} | ${cmd_jq} '. | if(.commissionState == "COMMISSIONED") then 1 else 0 end' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}