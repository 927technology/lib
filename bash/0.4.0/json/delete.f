json.delete() {
  # local variables
  local _json="{}"
  local _key=

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
    esac
    shift
  done

  # main
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c 'if( try( '"${_key}"' ) ) then del('"${_key}"') else . end' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}