is_ipv4() {
  # local variables
  local _octets=0

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local octet=

  while read -r _data; do
    if [[ -z "${_data}" ]]; then
      _exit_string=
      _exit_code=${exit_crit}
    
    else
      for octet in $( ${cmd_echo} ${_data} | ${cmd_sed} 's/\./\n/g' ); do
        if  [ ${octet} -ge 0    2>/dev/null ] &&
            [ ${octet} -le 254  2>/dev/null ]; then
          (( _octets++ ))
        
        else
          (( _error_count++ ))

        fi
      done
    fi

    if  [[ ${_octets} == 4 ]] &&
        [[ ${_error_count} == 0 ]]; then
      _exit_code=${exit_ok}
      _exit_string=${_data}

    else
      _exit_code=${exit_crit}

    fi
  done

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}