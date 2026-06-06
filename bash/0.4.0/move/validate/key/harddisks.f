move.validate.key.harddisks() {
  # local variables
  local _count=0
  local _endpoint_destination=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local host=
  local harddisk=

  # argument variables
  local _json=
  local _name=
  local _profile=
  local _type=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -t | --type )
        shift
        _type=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -j | --json )
        shift
        _json=$( ${cmd_echo} "${1}" | ${cmd_jq} -c )
      ;;
      -h | --host | -n | --name )
        shift
        _name=$( ${cmd_echo} "${1}" | lcase )
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
    move.coriolis.set.endpoint --name ${_endpoint_destination} --profile ${_profile} 2>/dev/null

    # harddisk transfer options
    for harddisk in $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.harddisks[]' ); do 
      # zero loop variables

      if [[ $( ${cmd_echo} ${harddisk} | ${cmd_jq} '.olvm.domain' ) != null ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [SET]      End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: .harddisks[${_count}].olvm.domain, VALUE: $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"

        # check value exists in endpoint
        if [[ $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --profile ${_profile} --type storage_mappings | ${cmd_jq} '[ .[] | select( .name == "'"$( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"'") ] | length' ) > 0 ]]; then
          # value exists
          shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: .harddisks[${_count}].olvm.domain, VALUE: $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"

        else
          # value does not exist
          if [[ $( ${cmd_echo} ${harddisk} | ${cmd_jq} '.olvm.domain' ) != null ]]; then
            shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [INVALID]  End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: .harddisks[${_count}].olvm.domain, VALUE: $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"
            shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [FIX]      move.set.transfers --host ${_name} --key .harddisks[${_count}].olvm.domain --profile ${_profile} --value <storage_domain>"
            shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [STORAGE_DOMAIN]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --type storage_mappings --output name ) | ${cmd_sed} 's/\ /, /g' )"

            (( _error_count++ ))
          
          fi
        fi

      else
        shell.log "${FUNCNAME}(${_profile}) - [UNSET]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: .harddisks[${_count}].olvm.domain"
        shell.log "${FUNCNAME}(${_profile}) - [FIX]      move.set.transfers --host ${_name} --key .harddisks[${_count}].olvm.domain --profile ${_profile} --value <storage_domain>"
        shell.log "${FUNCNAME}(${_profile}) - [STORAGE_DOMAIN]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --type storage_mappings --output name ) | ${cmd_sed} 's/\ /, /g' )" 

        (( _error_count++ ))

      fi

      (( _count++ ))

    done
  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}