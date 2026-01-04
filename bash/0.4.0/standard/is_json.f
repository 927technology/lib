is_json() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  while read -r _data; do
    ${cmd_echo} "${_data}" | ${cmd_jq} > /dev/null 2>&1
    if [[ ${?} == ${exit_ok} ]]; then
      _exit_code=${exit_ok}
      _exit_string=${true}
    else  
      _exit_code=${exit_crit}
      _exit_string=${false}
    fi
  done

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}