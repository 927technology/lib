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
  local _naemon=${false}
  local _name=
  local _profile=
  local _type=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -t | --type )
        shift
        _type="${1}"
      ;;
      -j | --json )
        shift
        _json=$( ${cmd_echo} "${1}" | ${cmd_jq} -c )
      ;;
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

    # harddisk transfer options
    for harddisk in $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.harddisks[]' ); do 
      # zero loop variables

      if [[ $( ${cmd_echo} ${harddisk} | ${cmd_jq} '.olvm.domain' ) != null ]]; then
        if [[ ${_naemon} == ${false} ]]; then
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SET]      End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: .harddisks[${_count}].olvm.domain, VALUE: $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"
        
        fi

        # check value exists in endpoint
        if [[ $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --type storage_mappings | ${cmd_jq} '[ .[] | select( .name == "'"$( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"'") ] | length' ) > 0 ]]; then
          # value exists
          if [[ ${_naemon} == ${false} ]]; then
            shell.log "${_exit_string}${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: .harddisks[${_count}].olvm.domain, VALUE: $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"

          else
            _exit_string+="[VALID] .harddisks[${_count}].olvm.domain = $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"
            _exit_string+="\n[Size]     $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.vsphere.capacitygb' )GB"
            _exit_string+="\n\n"

          fi
        else
          # value does not exist
          if [[ $( ${cmd_echo} ${harddisk} | ${cmd_jq} '.olvm.domain' ) != null ]]; then
            if [[ ${_naemon} == ${false} ]]; then
              shell.log "${_exit_string}${FUNCNAME}(${MOVE_PROFILE}) - [INVALID]  End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: .harddisks[${_count}].olvm.domain, VALUE: $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"
              shell.log "${_exit_string}${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .harddisks[${_count}].olvm.domain --profile ${_profile} --value <storage_domain>"
              shell.log "${_exit_string}${FUNCNAME}(${MOVE_PROFILE}) - [STORAGE_DOMAIN]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type storage_mappings --output name ) | ${cmd_sed} 's/\ /, /g' )"

            else
              _exit_string+="[INVALID] .harddisks[${_count}].olvm.domain = $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )"
              _exit_string+="\n[Size]     $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.vsphere.capacitygb' )GB"
              _exit_string+="\n[FIX]      move.set.transfers --host ${_name} --key .harddisks[${_count}].olvm.domain --profile ${_profile} --value <storage_domain>"
              _exit_string+="\n[STORAGE_DOMAIN]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type storage_mappings --output name ) | ${cmd_sed} 's/\ /, /g' )"
              _exit_string+="\n\n"
            
            fi

            (( _error_count++ ))
          
          fi
        fi

      else
        if [[ ${_naemon} == ${false} ]]; then
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [UNSET]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: .harddisks[${_count}].olvm.domain"
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .harddisks[${_count}].olvm.domain --profile ${_profile} --value <storage_domain>"
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [STORAGE_DOMAIN]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type storage_mappings --output name ) | ${cmd_sed} 's/\ /, /g' )" 

        else 
          _exit_string+="[UNSET] .harddisks[${_count}].olvm.domain"
          _exit_string+="\n[Size]     $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.vsphere.capacitygb' )GB"
          _exit_string+="\n  [FIX]             move.set.transfers --host ${_name} --key .harddisks[${_count}].olvm.domain --profile ${_profile} --value <storage_domain>"
          _exit_string+="\n  [STORAGE_DOMAIN]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type storage_mappings --output name ) | ${cmd_sed} 's/\ /, /g' )" 
          _exit_string+="\n\n"
        fi

        (( _error_count++ ))

      fi

      # ${cmd_echo}
      (( _count++ ))

    done
  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_unkn} || _exit_code=${exit_ok}
  if [[ ${_naemon} == ${true} ]]; then
    if [[ ${_exit_code} > 0 ]]; then
      _exit_string="[PROBLEM]\n-----------------------------\n\n${_exit_string}"

    else
      _exit_string="[SUCCESS]\n-----------------------------\n\n${_exit_string}"

    fi

    ${cmd_echo} -e ${_exit_string}

  fi

  return ${_exit_code}
}