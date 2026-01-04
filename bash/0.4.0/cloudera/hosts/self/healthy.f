cloudera.hosts.self.healthy() {
  # description

  # variables
  local _api_version=v19

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # description

  # variables
  local _api_version=v19

  # control variables
  # none

  # argument variables
  # none

  # parse arguments
  # none

  # main
  _exit_string=$( cloudera.hosts.self ${@} | ${cmd_jq} -r 'if( .healthSummary == "GOOD" ) then ( if( .commissionState == "COMMISSIONED" ) then ( if( .maintenanceMode == false ) then '${true}' else '${false}' end ) else '${false}' end ) else '${false}' end' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}