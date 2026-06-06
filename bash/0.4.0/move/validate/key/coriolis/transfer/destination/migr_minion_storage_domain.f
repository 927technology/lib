move.validate.key.coriolis_transfer_destination_migr_minion_storage_domain() {
  # local variables
  local _count=0
  local _endpoint_destination=
  local _key=.coriolis.transfer.destination.migr_minion_storage_domain
  local _type=migr_minion_storage_domain

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=
  local host=

  # argument variables
  local _name=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
     esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  if   [[ ! -z ${_name} ]]; then
    _json=$( move.list.transfers --name ${_name} --profile ${_profile} | ${cmd_jq} -c '.[]' )

  fi

  # set endpoints
  _endpoint_destination=$( ${cmd_echo} "${_json}" | ${cmd_jq} -r  '.coriolis.transfer.endpoint.destination' )
  _endpoint_source=$( ${cmd_echo} "${_json}" | ${cmd_jq} -r  '.coriolis.transfer.endpoint.source' )

  if [[ ! -z ${_endpoint_destination} ]]; then
    # set coriolis endpoint
    move.coriolis.set.endpoint --name ${_endpoint_destination} --profile ${_profile}


    if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} "${_key}" ) != null ]]; then
      shell.log "${FUNCNAME}(${_profile}) - [SET]      End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: ${_key}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" )"

      # check value exists in endpoint
      if [[ $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --type ${_type} --profile ${_profile} | ${cmd_jq} '[ .[] | select( .name == "'"$( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" )"'") ] | length' ) > 0 ]]; then
        # value exists
        shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: ${_key}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" )"

      else
        # value does not exist
        if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} "${_key}" ) != null ]]; then
          shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [INVALID]  End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: "${_key}", VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" )"
          shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [FIX]      move.set.transfers --host ${_name} --key "${_key}" --profile ${_profile} --value <$( ${cmd_echo} ${_type} | lcase )>"
          shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [$( ${cmd_echo} ${_type}S | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${_type} --output name --profile ${_profile} ) | ${cmd_sed} 's/\ /, /g' )"

          (( _error_count++ ))
        
        fi
      fi

    else
      shell.log "${FUNCNAME}(${_profile}) - [UNSET]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: ${_key}"
      shell.log "${FUNCNAME}(${_profile}) - [FIX]      move.set.transfers --host ${_name} --key ${_key} --profile ${_profile} --value <$( ${cmd_echo} ${_type} | lcase )>"
      shell.log "${FUNCNAME}(${_profile}) - [$( ${cmd_echo} ${_type}S | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${_type} --output name --profile ${_profile} ) | ${cmd_sed} 's/\ /, /g' )" 

      (( _error_count++ ))

    fi

    (( _count++ ))

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}