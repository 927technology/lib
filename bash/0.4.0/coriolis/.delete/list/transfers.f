coriolis.list.transfers() {
  # local variables
  local _json=
  local _path=~move/coriolis

  # argument variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  _json=$( ${cmd_coriolis} transfer list -f json 2>/dev/null | ${cmd_jq} -c 'if( . != null ) then . else "{}" end' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

   
  # ${cmd_cat} ${_path}/transfers/*.json 2>/dev/null | ${cmd_jq} -sc && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  _exit_string="${_json}"
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}