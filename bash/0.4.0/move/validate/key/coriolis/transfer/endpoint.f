move.validate.key.coriolis_transfer_endpoint() {
  # local variables
  local _direction=destination
  local _json_endpoints=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  # local _json="{}"
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -d | --direction )
        shift
        case $( ${cmd_echo} "${1}" | lcase ) in 
          destination | source )
            _direction=$( ${cmd_echo} "${1}" | lcase )
              case ${_direction} in
                destination )
                  _endpoint_type=olvm
                ;;
                source )
                  _endpoint_type=vmware_vsphere
                ;;
                * )
                  shell.log "${FUNCNAME}(${_profile}) - [SYNTAX]      Error"

                  return ${exit_crit}
                ;;
              esac
          ;;
          * ) return ${exit_crit} ;;

        esac
      ;;
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

  _json=$( move.list.transfers --name ${_name} --profile ${_profile} | ${cmd_jq} -c '.[]' )

  # get endpoints
  ## fix - this is returning all endpoints not just directional ones source/destination
  #  _json_endpoints=$( move.coriolis.list.endpoints | ${cmd_jq} -c '.[] | select( .Type == "'"${_endpoint_type}"'" )' )
  _json_endpoints=$( move.coriolis.list.endpoints --profile ${_profile} | ${cmd_jq} -c '.[]' )
  echo $_json_endpoints | ${cmd_jq} 

  # value is not null
  if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '.coriolis.transfer.endpoint.'${_direction} ) != null ]]; then
    shell.log "${FUNCNAME}(${_profile}) - [SET]      VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.${_direction}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer.endpoint.'${_direction} )"

    # check value exists in endpoints
    if [[ $( ${cmd_echo} ${_json_endpoints} | ${cmd_jq} -c '[ . | select( ( .Name | ascii_downcase ) == "'"$( ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer.endpoint.'${_direction} )"'" ) ] | length' ) > 0 ]]; then
      shell.log "${FUNCNAME}(${_profile}) - [VALID]    VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.${_direction}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer.endpoint.'${_direction} )"

    # value does not exist in endpoints
    else
      if [[ ${_value} != null ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [INVALID]  VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.${_direction}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer.endpoint.'${_direction} )"
        shell.log "${FUNCNAME}(${_profile}) - [FIX]      move.set.transfers --host $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ) --key .coriolis.transfer.endpoint.${_direction} --profile ${_profile} --value <endpoint>"
        shell.log "${FUNCNAME}(${_profile}) - [ENDPOINT] $( ${cmd_echo} ${_json_endpoints} | ${cmd_jq} -r '.Name' )"
        (( _error_count++ ))
      
      fi
    fi

  # value is null
  else
echo 50
    shell.log "${FUNCNAME}(${_profile}) - [UNSET]    VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.endpoint.${_direction}"
    shell.log "${FUNCNAME}(${_profile}) - [FIX]      move.set.transfers --host $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ) --key .coriolis.transfer.endpoint.${_direction} --value <endpoint>"
    shell.log "${FUNCNAME}(${_profile}) - [ENDPOINT] $( ${cmd_echo} ${_json_endpoints} | ${cmd_jq} -r '.Name' )"
    (( _error_count++ ))
  
  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}