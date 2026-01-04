
is_integer() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  while read -r _data; do
    if  [ ${_data} -ge 0 2>/dev/null ] || \
        [ ${_data} -le 0 2>/dev/null ]; then

        _exit_string=${_data}
        _exit_code=${exit_ok}
    else
        _exit_code=${exit_crit} 

    fi
  done

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}
