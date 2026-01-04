json.set() {
  # dependancies
  # json/set

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
  if    [[ -z ${_value} ]]; then
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'   |= null' )
    _exit_code=${exit_ok}
    
  elif  [[ ${_value} == {} ]]; then
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'   |= {}' )
    _exit_code=${exit_ok}
 
  elif  [[ ${_value} == [] ]]; then
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'   |= []' )
    _exit_code=${exit_ok}

  elif  [[ $( ${cmd_echo} "${_value}" | is_integer >/dev/null 2>&1; ${cmd_echo} ${?} ) == ${exit_ok} ]]; then
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'     |= '${_value} )
    _exit_code=${exit_ok}

  elif  [[ $( ${cmd_echo} "${_value}" | is_string >/dev/null 2>&1; ${cmd_echo} ${?} ) == ${exit_ok} ]]; then
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'     |= "'"${_value}"'"' )
    _exit_code=${exit_ok}

  else
    _exit_code=${exit_crit}

  fi

  [[ ${?} != ${exit_ok} ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}