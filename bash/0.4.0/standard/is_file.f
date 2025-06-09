is_file() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  while read -r _data; do
    if [[ -f ${_data} ]]; then
      _exit_string=${true}

    else  
      _exit_string=${false}

    fi
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  done

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}