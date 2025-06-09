is_integer() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  while read -r _data; do
    case ${_data} in
      ''|*[!0-9]*) 
        _exit_string=${false}
        _exit_code=${exit_ok}
      ;;
      *) 
        _exit_string=${true}
        _exit_code=${exit_ok} 
      ;;
    esac
  done

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}