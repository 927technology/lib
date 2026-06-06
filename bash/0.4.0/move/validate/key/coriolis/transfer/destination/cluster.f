move.validate.key.coriolis_transfer_destination_cluster() {
  # local variables
  local _direction=destination
  local _json_endpoints=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _json="{}"

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
     esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  [[ -z ${_profile} ]] && return ${exit_crit}

  _json=$( move.list.transfers --name ${_name} | ${cmd_jq} -c '.[]' )

  # get endpoints
  _json_endpoints=$( move.coriolis.list.endpoints | ${cmd_jq} -c '.[] | select( .Type == "'"${_endpoint_type}"'" )' )

  # value is not null
  if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '.coriolis.transfer.destination.cluster' ) != null ]]; then
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SET]      VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.cluster, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer.destination.cluster' )"

  # value is null
  else
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [UNSET]    VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.cluster"
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ) --key .coriolis.transfer.destination.cluster --value <olvm cluster>"
    (( _error_count++ ))
  
  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}