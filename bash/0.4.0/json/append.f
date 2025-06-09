json.append() {
  # local variables
  local _json="{}"
  local _key=
  local _value=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j  | --json )
        shift
        _json="${1}"
      ;;
      -k  | --key )
        shift
        _key="${1}"
      ;;
      -v  | --value )
        shift
        _value="${1}"
      ;;
    esac
    shift
  done

  # main
  case $( ${cmd_echo} "${_value}" | is_integer ) in
    ${true} )
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'                    |=.+ '${_value} )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

    ;;
    ${false} )
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'                    |=.+ "'"${_value}"'"' )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

    ;;
  esac

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}