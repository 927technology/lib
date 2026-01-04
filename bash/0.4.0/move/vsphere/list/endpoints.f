move.vsphere.list.endpoints() {
  # local variables
  local _json="{}"
  local _path=~move/move

  # argument variables
  local _output=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -o | --output )
        shift
        _output=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}

  if [[ ! -z ${_profile} ]]; then
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '.[] | select(( .name == "'"${_profile}"'" ) and .enable == '${true}' ).vsphere[] | select( .enable == '${true}' )' )

  else
    (( _error_count++ ))

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      name                 ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.endpoint'                                                                ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}

