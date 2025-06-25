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
  case $( ${cmd_echo} "${_value}" | is_integer ) in
    ${true} )
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'     |= '${_value} )
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

    ;;
    ${false} )
      if    [[ -z ${_value} ]]; then
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'   |= null' )
      
      elif  [[ $( ${cmd_echo} ${_value} | is_json ) == ${true} ]]; then
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'   |= '${_value} )

      elif  [[ ${_value} == {} ]]; then
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'   |= {}' )
 
      elif  [[ ${_value} == [] ]]; then
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'   |= []' )

      else
        _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c "${_key}"'   |= "'"${_value}"'"' )
      
      fi
      [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

    ;;
  esac

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}