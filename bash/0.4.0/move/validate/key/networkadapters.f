move.validate.key.networkadapters() {
  # local variables
  local _count=0
  local _endpoint_destination=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _json=
  local _naemon=${false}
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
      -N | --naemon )
        _naemon=${true}
     esac
    shift
  done

  # main
  if   [[ ! -z ${_name} ]]; then
    _json=$( move.list.transfers --name ${_name} | ${cmd_jq} -c '.[]' )

  fi

  _endpoint_destination=$( ${cmd_echo} ${_json} | ${cmd_jq} -r  '.coriolis.transfer.endpoint.destination' )
  _endpoint_source=$( ${cmd_echo} ${_json} | ${cmd_jq} -r  '.coriolis.transfer.endpoint.source' )

  if [[ ! -z ${_endpoint_destination} ]]; then
    # network adapter transfer options
    for networkadapter in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.networkadapters[]' ); do 
      
      # olvm datacenter
      if [[ $( ${cmd_echo} ${networkadapter} | ${cmd_jq} '.olvm.datacenter' ) != null ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SET]      End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .networkadapters[${_count}].olvm.datacenter, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.datacenter' )"

        # check datacenter exists in networks
        if [[ $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output olvm_datacenter | ${cmd_jq} '. | index("'"$( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.datacenter' )"'") | if( . != null ) then '${true}' else '${false}' end' )  == ${true} ]]; then
          if [[ ${_naemon} == ${false} ]]; then
            # value exists
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .networkadapters[${_count}].olvm.datacenter, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.datacenter' )"

          else
            _exit_string+="[VALID]    .networkadapters[${_count}].olvm.datacenter, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.datacenter' )"
          
          fi

          # olvm vlan
          if [[ $( ${cmd_echo} ${networkadapter} | ${cmd_jq} '.olvm.vlan' ) != null ]]; then
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SET]      End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .networkadapters[${_count}].olvm.vlan, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' )"

            # check value vlan exists
            # if [[ $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --type ${coriolis_transfer_destination_key} | ${cmd_jq} '[ .[] | select( .name == "'"$( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' )"'") ] | length' ) > 0 ]]; then
            if [[ $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output vlan | ${cmd_jq} '. | index( '$( ${cmd_echo} ${networkadapter} | ${cmd_jq} .olvm.vlan )' ) | if( . != null ) then '${true}' else '${false}' end' )  == ${true} ]]; then
              if [[ ${_naemon} == ${false} ]]; then
                # value exists
                shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .networkadapters[${_count}].olvm.vlan, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' )"

              else
                _exit_string+="\n\n[VALID]    .networkadapters[${_count}].olvm.vlan, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' )"
                _exit_string+="\n\n"

              fi
            else
              # value does not exist
              if [[ $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' ) != null ]]; then
                if [[ ${_naemon} == ${false} ]]; then
                  shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [INVALID]  End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .networkadapters[${_count}].olvm.vlan, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' )"
                  shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .networkadapters[${_count}].olvm.vlan --profile ${_profile} --value <network>"
                  shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VLAN]     $( ${cmd_echo} $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output vlan | ${cmd_jq} -r '.[]' )| ${cmd_sed} 's/\ /, /g')"  
                
                else
                  _exit_string+="\n\n[INVALID]  .networkadapters[${_count}].olvm.vlan, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' )"
                  _exit_string+="\n[FIX]      move.set.transfers --host ${_name} --key .networkadapters[${_count}].olvm.vlan --profile ${_profile} --value <network>"
                  _exit_string+="\n[VLAN]     $( ${cmd_echo} $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output vlan | ${cmd_jq} -r '.[]' )| ${cmd_sed} 's/\ /, /g')"  
                
                fi
                
                (( _error_count++ ))
              
              fi
            fi

          else
            if [[ ${_naemon} == ${false} ]]; then
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [UNSET]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .networkadapters[${_count}].olvm.vlan"
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .networkadapters[${_count}].olvm.vlan --profile ${_profile} --value <vlan>"
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VLAN]     $( ${cmd_echo} $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output vlan | ${cmd_jq} -r '.[]' )| ${cmd_sed} 's/\ /, /g')"  

            else
              _exit_string+="\n\n[UNSET]    .networkadapters[${_count}].olvm.vlan"
              _exit_string+="\n[FIX]      move.set.transfers --host ${_name} --key .networkadapters[${_count}].olvm.vlan --profile ${_profile} --value <vlan>"
              _exit_string+="\n[VLAN]     $( ${cmd_echo} $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output vlan | ${cmd_jq} -r '.[]' )| ${cmd_sed} 's/\ /, /g')"  

            fi   

            (( _error_count++ ))

          fi

        else
          # value does not exist
          if [[ $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' ) != null ]]; then
            if [[ ${_naemon} == ${false} ]]; then
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [INVALID]  End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .networkadapters[${_count}].olvm.vlan, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' )"
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .networkadapters[${_count}].olvm.vlan --profile ${_profile} --value <network>"
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [NETWORK]  $( ${cmd_echo} $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output name | ${cmd_grep} -v ovirtmgmt ) | ${cmd_sed} 's/\ /, /g' )"
            
            else
              _exit_string+="[INVALID]  .networkadapters[${_count}].olvm.vlan, VALUE: $( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.vlan' )"
              _exit_string+="\n[FIX]      move.set.transfers --host ${_name} --key .networkadapters[${_count}].olvm.vlan --profile ${_profile} --value <network>"
              _exit_string+="\n[NETWORK]  $( ${cmd_echo} $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output name | ${cmd_grep} -v ovirtmgmt ) | ${cmd_sed} 's/\ /, /g' )"

            fi
      
            (( _error_count++ ))
          
          fi
        fi

      else
        if [[ ${_naemon} == ${false} ]]; then
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [UNSET]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .networkadapters[${_count}].olvm.datacenter"
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .networkadapters[${_count}].olvm.datacenter --profile ${_profile} --value <datacenter>"
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [DATACENTER]  $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output olvm_datacenter | ${cmd_jq} -r '.[]' | ${cmd_sed} 's/\ /, /g' )"  
    
        else
          _exit_string+="[UNSET]     .networkadapters[${_count}].olvm.datacenter"
          _exit_string+="\n[FIX]      move.set.transfers --host ${_name} --key .networkadapters[${_count}].olvm.datacenter --profile ${_profile} --value <datacenter>"
          _exit_string+="\n[DATACENTER]  $( move.coriolis.list.endpoints.networks --endpoint ${_endpoint_destination} --output olvm_datacenter | ${cmd_jq} -r '.[]' | ${cmd_sed} 's/\ /, /g' )"  
  
        fi
    
        (( _error_count++ ))

      fi

      (( _count++ ))
    done

  else
    if [[ ${_naemon} == ${false} ]]; then
      shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE]  End Point: NOT SET , VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.destination' )"
      shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [ENDPOINT]     $( ${cmd_echo} $( move.coriolis.list.endpoints --output name )| ${cmd_sed} 's/\ /, /g' )"  

    else
      _exit_string+="[FAILURE]  End Point: NOT SET , VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.destination'"
      _exit_string+="\n[ENDPOINT]     $( ${cmd_echo} $( move.coriolis.list.endpoints --output name )| ${cmd_sed} 's/\ /, /g' )"  

    fi

    (( _error_count++ ))

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