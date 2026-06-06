move.validate.key.coriolis_transfer_destination() {
  # local variables
  local _coriolis_transfer_destination_keys=(                                                       \
    cluster                                                                                         \
    delete_protected                                                                                \
    leave_migrated_vms_off                                                                          \
    migr_blank_template                                                                             \
    migr_minion_cluster                                                                             \
    migr_minion_storage_domain                                                                      \
    network_map                                                                                     \
    optimized_for                                                                                   \
    os_release                                                                                      \
    migr_template_map                                                                               \
    set_dhcp                                                                                        \
    storage_mappings                                                                                \
    vm_pool                                                                                         \
    source                                                                                          \
  )
  local _endpoint_destination=
  local _migr_template_map_os_id=
  local _migr_template_map_oss=
  local _os_family=
  local _path=~move/move
  local _tmp_file$( ${cmd_mktemp} )
  local _value=
  
  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _json=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -j | --json )
        shift
        _json=$( ${cmd_echo} "${1}" | ${cmd_jq} -c )
      ;;
     esac
    shift
  done

  # main
  # create network map(s)
  if    [[ ! -z ${_name} ]]; then
    move.list.transfers --host ${_name} | ${cmd_jq} -c > ${_tmp_file}

  elif  [[ ! -z ${_filter} ]]; then
    move.list.transfers --filter ${_filter} | ${cmd_jq} -c > ${_tmp_file}

  else
    move.list.transfers | ${cmd_jq} -c > ${_tmp_file}
  
  fi

  for host in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c '.[]' ); do
    # zero out loop variables
    _count_harddisks=0
    _count_networkadapters=0
    _endpoint_destination=
    _migr_template_map_oss=
    _os_family=
    _value=
    _endpoint_destination=$( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.transfer.endpoint.destination' )
    _os_family=$( ${cmd_echo} ${host} | ${cmd_jq} -r '.move.coriolis.transfer.destination.os.family' )


    # coriolis transfer destination values
    for coriolis_transfer_destination_key in "${_coriolis_transfer_destination_keys[@]}"; do
      # set value
      _value=$( ${cmd_echo} ${host} | ${cmd_jq} -r --arg key "${coriolis_transfer_destination_key}" '.coriolis.transfer.destination | .[$key]' )

      # check values
      ## null
      case "${coriolis_transfer_destination_key}" in
        migr_minion_cluster | network_map | source | storage_mappings | vm_pool )
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SKIP]     End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}"

        ;;
        *  )
          if [[ ${_value} != null ]]; then
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SET]      End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, VALUE: ${_value}"
          else
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [UNSET]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}"

            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .coriolis.transfer.destination.${coriolis_transfer_destination_key} --value <${coriolis_transfer_destination_key}>"
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [$( ${cmd_echo} ${coriolis_transfer_destination_key} | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${coriolis_transfer_destination_key} --output name ) | ${cmd_sed} 's/\ /, /g' )"  
            (( _error_count++ ))
          fi 
        ;;
      esac

      case "${coriolis_transfer_destination_key}" in
        delete_protected | leave_migrated_vms_off |  set_dhcp )
          if  [[ ${_value} == true  ]] ||                                                           \
              [[ ${_value} == false ]]; then
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, VALUE: ${_value}"
          else
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, VALUE: ${_value}"
            (( _error_count++ ))

          fi

        ;;
        cluster | migr_blank_template | migr_blank_template | migr_minion_storage_domain )
          # check value exists in options
          if [[ $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --type ${coriolis_transfer_destination_key} | ${cmd_jq} '[ .[] | select( .name == "'"${_value}"'") ] | length' ) > 0 ]]; then
            # value exists
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, VALUE: ${_value}"

          else
            # value does not exist
            if [[ ${_value} != null ]]; then
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [INVALID]  End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, VALUE: ${_value}"
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .coriolis.transfer.destination.${coriolis_transfer_destination_key} --value <${coriolis_transfer_destination_key}>"
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [$( ${cmd_echo} ${coriolis_transfer_destination_key} | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${coriolis_transfer_destination_key} --output name ) | ${cmd_sed} 's/\ /, /g' )"  
              (( _error_count++ ))
            
            fi
          
          fi

        ;;

        migr_template_map )
          # set migr_templates for each os
          case ${_os_family} in
            linux   ) _migr_template_map_oss=linux                                                  ;;
            windows ) _migr_template_map_oss=linux,windows                                          ;;
          esac

          for migr_template_map_os in $( ${cmd_echo} ${_migr_template_map_oss} | ${cmd_sed} 's/,/\n/g' ) ; do
            for migr_template_map in $( ${cmd_echo} ${_value} ); do
              # zero loop variables
              _migr_template_map_os_id=

              # set os id
              _migr_template_map_os_id=$( ${cmd_echo} ${migr_template_map} | ${cmd_jq} -r 'if( try( ."'"${migr_template_map_os}"'" ) != null ) then ."'"${migr_template_map_os}"'" else "" end' )

              if [[ ! -z ${_migr_template_map_os_id} ]]; then
                shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, OS: ${migr_template_map_os}, VALUE: $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --type ${coriolis_transfer_destination_key} | ${cmd_jq} -r '.[] | select( .id == "'"${_migr_template_map_os_id}"'" ).name' )"
              
              else
                shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [UNSET]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, OS: ${migr_template_map_os}"
                shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .coriolis.transfer.destination.${coriolis_transfer_destination_key} --value ${migr_template_map_os}:<${coriolis_transfer_destination_key}>"
                shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [$( ${cmd_echo} ${coriolis_transfer_destination_key} | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${coriolis_transfer_destination_key} | ${cmd_jq} '.[].name' ) | ${cmd_sed} 's/\" /\", /g' )"  
                (( _error_count++ ))

              fi
            done
          done

        ;;
        optimized_for )
          # check value exists in options
          if [[ $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --type ${coriolis_transfer_destination_key} | ${cmd_jq} '[ .[] | contains("'"${_value}"'") ] | length' ) > 0 ]]; then
            # value exists
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, VALUE: ${_value}"

          else
            # value does not exist
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [INVALID]  End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, VALUE: ${_value}"
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .coriolis.transfer.destination.${coriolis_transfer_destination_key} --value <${coriolis_transfer_destination_key}>"
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [$( ${cmd_echo} ${coriolis_transfer_destination_key} | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${coriolis_transfer_destination_key} | ${cmd_jq} -r ) | ${cmd_sed} 's/\ /, /g' )"  
            (( _error_count++ ))
          
          fi

        ;;
        os_release )
          if [[ $( move.coriolis.list.endpoints.destination.options --endpoint ${_endpoint_destination} --type ${coriolis_transfer_destination_key} | ${cmd_jq} '[ .[] | select( .id == "'"${_value}"'" ) ] | length' ) > 0 ]]; then
              # value exists
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, VALUE: ${_value}"

            else
              # value does not exist
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [INVALID]  End Point: ${_endpoint_destination}, VM: $( ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ), KEY: .coriolis.transfer.destination.${coriolis_transfer_destination_key}, VALUE: ${_value}"
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host ${_name} --key .coriolis.transfer.destination.${coriolis_transfer_destination_key} --value <${coriolis_transfer_destination_key}>"
              shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [$( ${cmd_echo} ${coriolis_transfer_destination_key} | ucase )]  $( ${cmd_echo} $( move.coriolis.list.endpoints.destination.options --endpont ${_endpoint_destination} --type ${coriolis_transfer_destination_key} | ${cmd_jq} -r ) | ${cmd_sed} 's/\ /, /g' )"  
              (( _error_count++ ))
            
          fi

        ;;

      esac
    done
  done

  # exit
  [[ -f ${_tmp_file} ]] && ${cmd_rm} --force ${_tmp_file}
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}