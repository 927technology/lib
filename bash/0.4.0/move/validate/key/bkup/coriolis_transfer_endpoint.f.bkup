move.validate.key.coriolis_transfer_endpoint() {
  # local variables
  local _json_endpoints=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _direction=
  local _json=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -d | --direction )
        shift
        _direction="${1}"
      ;;
      -j | --json )
        shift
        _json=$( ${cmd_echo} "${1}" | ${cmd_jq} -c )
      ;;
     esac
    shift
  done

  # main
  case ${_direction} in
    destination )
      _endpoint_type=olvm
    ;;
    source )
      _endpoint_type=vmware_vsphere
    ;;
    * )
      shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SYNTAX]      Error"

      return ${exit_crit}
    ;;
  esac

  # get endpoints
  _json_endpoints=$( move.coriolis.list.endpoints | ${cmd_jq} -c '.[] | select( .Type == "'"${_endpoint_type}"'" )' )

  # value is not null
  if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '.coriolis.transfer.endpoint.'${_direction} ) != null ]]; then
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SET]      VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.${_direction}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer.endpoint.'${_direction} )"

    # check value exists in endpoints
    if [[ $( ${cmd_echo} ${_json_endpoints} | ${cmd_jq} -c '[ . | select( ( .Name | ascii_downcase ) == "'"$( ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer.endpoint.'${_direction} )"'" ) ] | length' ) > 0 ]]; then
      shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.${_direction}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer.endpoint.'${_direction} )"

    # value does not exist in endpoints
    else
      if [[ ${_value} != null ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [INVALID]  VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.${_direction}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer.endpoint.'${_direction} )"
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ) --key .coriolis.transfer.endpoint.${_direction} --value <endpoint>"
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [ENDPOINT] $( ${cmd_echo} ${_json_endpoints} | ${cmd_jq} -r '.Name' )"
        (( _error_count++ ))
      
      fi
    fi

  # value is null
  else
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [UNSET]    VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.${_direction}, KEY: .coriolis.transfer.endpoint.${_direction}"
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ) --key .coriolis.transfer.endpoint.${_direction} --value <endpoint>"
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [ENDPOINT] $( ${cmd_echo} ${_json_endpoints} | ${cmd_jq} -r '.Name' )"
    (( _error_count++ ))
  
  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}