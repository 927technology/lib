move.validate.key.coriolis_transfer_destination_migr-blank-template() {
  # local variables
  local _count=0
  local _endpoint_destination=
  local _key=.coriolis.transfer.destination.migr_blank_template
  local _type=migr_blank_template

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=
  local host=

  # argument variables
  local _naemon=${false}
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
        _profile="${1}"
      ;;
      -N | --naemon )
        _naemon=${true}
     esac
    shift
  done

  # main
  if   [[ ! -z ${_name} ]]; then
    _json=$( move.list.transfers --name ${_name} --profile ${_profile} | ${cmd_jq} -c '.[]' )

  fi

  # set endpoints
  _endpoint_destination=$( ${cmd_echo} "${_json}" | ${cmd_jq} -r  '.coriolis.transfer.endpoint.destination' )
  _endpoint_source=$( ${cmd_echo} "${_json}" | ${cmd_jq} -r  '.coriolis.transfer.endpoint.source' )

  if [[ ! -z ${_endpoint_destination} ]]; then
    # set coriolis endpoint
    move.coriolis.set.endpoint --name ${_endpoint_destination}


    if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} "${_key}" ) != null ]]; then
      if [[ ${_naemon} == ${false} ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [SET]      End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: ${_key}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" )"
      
      fi

      # check value exists in endpoint
      if [[ $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --type ${_type} | ${cmd_jq} '[ .[] | select( .name == "'"$( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" )"'") ] | length' ) > 0 ]]; then
        # value exists
        if [[ ${_naemon} == ${false} ]]; then
          shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: ${_key}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" )"

        else
          _exit_string+="[VALID] ${_key} = $( ${cmd_echo} ${_json} | ${cmd_jq} -r ${_key} )"
          _exit_string+="\n\n"

        fi
      else
        # value does not exist
        if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} "${_key}" ) != null ]]; then
          if [[ ${_naemon} == ${false} ]]; then
            shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [INVALID]  End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: "${_key}", VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" )"
            shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [FIX]      move.set.transfers --host ${_name} --key "${_key}" --profile ${_profile} --value <$( ${cmd_echo} ${_type} | lcase )>"
            shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [$( ${cmd_echo} ${_type} | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${_type} --output name ) | ${cmd_sed} 's/\ /, /g' )"

          else
            _exit_string+="[INVALID]  ${_key} = $( ${cmd_echo} ${_json} | ${cmd_jq} -r ${_key} )"
            _exit_string+="\n[FIX]      move.set.transfers --host ${_name} --key ${_key} --profile ${_profile} --value <$( ${cmd_echo} ${_type} | lcase )>"
            _exit_string+="\n[$( ${cmd_echo} ${_type} | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${_type} --output name ) | ${cmd_sed} 's/\ /, /g' )"
            _exit_string+="\n\n"
          
          fi

          (( _error_count++ ))
        
        fi
      fi

    else
      if [[ ${_naemon} == ${false} ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [UNSET]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: ${_key}"
        shell.log "${FUNCNAME}(${_profile}) - [FIX]      move.set.transfers --host ${_name} --key .harddisks[${_count}].olvm.domain --profile ${_profile} --value <$( ${cmd_echo} ${_type} | lcase )>"
        shell.log "${FUNCNAME}(${_profile}) - [$( ${cmd_echo} ${_type} | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${_type} --output name ) | ${cmd_sed} 's/\ /, /g' )" 

      else 
        _exit_string+="[UNSET] ${_key}"
        _exit_string+="\n[FIX]             move.set.transfers --host ${_name} --key ${_key} --profile ${_profile} --value <$( ${cmd_echo} ${_type} | lcase )>"
        _exit_string+="\n[$( ${cmd_echo} ${_type} | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${_type} --output name ) | ${cmd_sed} 's/\ /, /g' )" 
        _exit_string+="\n\n"
      fi

      (( _error_count++ ))

    fi

    (( _count++ ))

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_unkn} || _exit_code=${exit_ok}
  if [[ ${_naemon} == ${true} ]]; then
    if [[ ${_exit_code} > 0 ]]; then
      _exit_string="[PROBLEM]\n-----------------------------\n\n${_exit_string}"

    else
      _exit_string="[SUCCESS] - $( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" )\n-----------------------------\n\n${_exit_string}"

    fi

    ${cmd_echo} -e ${_exit_string}

  fi

  return ${_exit_code}
}