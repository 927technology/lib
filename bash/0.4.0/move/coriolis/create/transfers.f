move.coriolis.create.transfers() {
  # description
  # WIP CM

  # local variables
  local _count_harddisks=0
  local _destination_keys=migr_blank_template,migr_minion_cluster,migr_minion_cluster,migr_minion_cluster
  local _json=
  local _json_backend_map="{}"
  local _json_destination_map="{}"
  local _json_migration_template_username_map="{}"
  local _json_migration_template_password_map="{}"
  local _json_network_map="{}"
  local _json_output="{}"
  local _json_storage_map="{}"
  local _json_user_script_map="{}"
  local _migr_user=
  local _os_family=
  local _path=~move/move
  local _tmp_file=$( ${cmd_mktemp} )
  local _user_script=

  # argument variables
  local _dryrun=${false}
  local _filter=
  local _name=
  local _type=live_migration
  local _verbose=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local harddisk=
  local host=
  local networkadapter=
  local key=
  local migr_user=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -dr | --dry-run )
        _dryrun=${true}
      ;;
      -f | --filter )
        shift
        _filter="${1}"
      ;;
      -h | --host | -n | --name)
        shift
        _name="${1}"
      ;;
      -p  | --profile | -n | --name )
        shift
        _profile="${1}"
      ;;
      -t | --type )
        shift
        _type=$( ${cmd_echo} "${1}" | lcase )
    
        case ${_type} in
          migration )
            _type=live_migration
          ;;
          replica | * )
            _type=replica
          ;;
        esac
      ;;
      -v | --verbose )
        shift
        _verbose=${true}
      ;;
    esac
    shift
  done
echo 0
  # main
  # set credentials
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}

  # create network map(s)
  if    [[ ! -z ${_name} ]]; then
    move.list.transfers --name ${_name} | ${cmd_jq} | ${cmd_jq} -c > ${_tmp_file}

  elif  [[ ! -z ${_filter} ]]; then
    move.list.transfers --filter ${_filter} | ${cmd_jq} -c > ${_tmp_file}

  fi

  for host in $( ${cmd_cat} "${_tmp_file}" | ${cmd_jq} -c '.[]' ); do
    # zero loop variables
    _os_family=
    _user_script=

    # set endpoint
    move.coriolis.set.endpoint --name $( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.transfer.endpoint.destination' )

    # get os family
    _os_family=$( ${cmd_echo} ${host} | ${cmd_jq} -r '.move.coriolis.transfer.destination.os.family' )


    # destination environment
    ## lookups
    for key in $( ${cmd_echo} ${_destination_keys} | ${cmd_sed} 's/,/\n/g' ); do
      if [[ $( ${cmd_echo} ${host} | ${cmd_jq} 'if( .coriolis.transfer.destination.'$key' != null ) then '${true}' else '${false}' end' ) == ${true} ]]; then
        host=$(                                                                                     \
          json.set                                                                                  \
            --json ${host}                                                                          \
            --key .coriolis.transfer.destination.${key}                                             \
            --value $(                                                                              \
              move.coriolis.list.endpoints.destination.options                                      \
                --type ${key} |                                                                     \
              ${cmd_jq} '.[] | select( .name == "'$( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.transfer.destination.'${key} )'" ).id' \
            )                                                                                       \
        )

      fi
    done

    ## migration passwords
    _json_migration_template_username_map=$( ${cmd_echo} ${host} | ${cmd_jq} -c 'if( .coriolis.transfer.destination.migr_template_username_map != null ) then .coriolis.transfer.destination.migr_template_username_map else empty end' )
    _json_migration_template_password_map=$( ${cmd_echo} ${host} | ${cmd_jq} -c 'if( .coriolis.transfer.destination.migr_template_password_map != null ) then .coriolis.transfer.destination.migr_template_password_map else empty end' )
    # for migr_user in $( ${cmd_echo} ${host} | ${cmd_jq} -r 'if( .coriolis.transfer.destination.migr_template_username_map != null ) then .coriolis.transfer.destination.migr_template_username_map else empty end' ); do
      # _json_migration_template_username_map=$(                                                      \
      #   json.set                                                                                    \
      #     --json                  ${_json_migration_template_username_map}                          \
      #     --key                   .${migr_user}                                                     \
      #     --value                 $( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} '.[] | select( .name == "'"${_profile}"'" ).coriolis[] | select( .name == "'${CORIOLIS_NAME}'").migr_map[] | select( .label == "'${migr_user}'" ).username' ) \
      # )

      # _json_migration_template_password_map=$(                                                      \
      #   json.set                                                                                    \
      #     --json                  ${_json_migration_template_password_map}                          \
      #     --key                   .${migr_user}                                                     \
      #     --value                 $( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} '.[] | select( .name == "'"${_profile}"'" ).coriolis[] | select( .name == "'${CORIOLIS_NAME}'").migr_map[] | select( .label == "'${migr_user}'" ).password' ) \
      # )
    # done

    # network adapters
    for networkadapter in $( ${cmd_echo} ${host} | ${cmd_jq} -c '.networkadapters[]' ); do
      _json_network_map=$(                                                                          \
        json.set                                                                                    \
          --json                  ${_json_network_map}                                              \
          --key                   .\"$( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.vsphere.networkname' )\" \
          --value                 $(                                                                \
            move.coriolis.list.endpoints.networks  |                                                \
            ${cmd_jq} '.[] | select(( .move.network.datacenter == "'"$( ${cmd_echo} ${networkadapter} | ${cmd_jq} -r '.olvm.datacenter' )"'" ) and  .move.network.vlan == '$( ${cmd_echo} ${networkadapter} | ${cmd_jq} '.olvm.vlan' )').id'  
          )                                                                                         \
      )

    done

    # default storage map
    # note:  storage mappings can be id or name, but id will not translate in the coriolis web
    # ui.  using name so there is no confusion when looking at that console
    _json_storage_map=$(                                                                            \
      json.set                                                                                      \
        --json                  ${_json_storage_map}                                                \
        --key                   .storage_mappings.default                                           \
        --value                 $(                                                                  \
          move.coriolis.list.endpoints.storage                                                      \
            --name              $( ${cmd_echo} ${host} | ${cmd_jq} -r '.harddisks[0].olvm.domain' ) \
            --output            name                                                                \
        )                                                                                           \
    )

    # zero out loop variables
    _count_harddisks=0
    _json_backend_map="{}"

    for harddisk in $( ${cmd_echo} ${host} | ${cmd_jq} -c '.harddisks[]' ); do
      # note:  storage mappings can be id or name, but id will not translate in the coriolis web
      # ui.  using name so there is no confusion when looking at that console

      # backend mappings - source
      _json_backend_map=$(                                                                          \
        json.set                                                                                    \
          --json                  ${_json_backend_map}                                              \
          --key                   .backend_mappings[${_count_harddisks}].source                     \
          --value                 $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.vsphere.filename.label' ) \
      )

      _json_backend_map=$(                                                                          \
        json.set                                                                                    \
          --json                  ${_json_backend_map}                                              \
          --key                   .backend_mappings[${_count_harddisks}].destination                \
          --value                 $(                                                                \
            move.coriolis.list.endpoints.storage                                                    \
              --name              $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )        \
              --output            name                                                              \
          )                                                                                         \
      )

      # storage mappings - disk id
      _json_storage_map=$(                                                                          \
        json.set                                                                                    \
          --json                  ${_json_storage_map}                                              \
          --key                   .storage_mappings.disk_mappings[${_count_harddisks}].disk_id      \
          --value                 $( ${cmd_echo} ${harddisk} | ${cmd_jq} '.id.index' )              \
      )

      _json_storage_map=$(                                                                          \
        json.set                                                                                    \
          --json                  ${_json_storage_map}                                              \
          --key                   .storage_mappings.disk_mappings[${_count_harddisks}].destination  \
          --value                 $(                                                                \
            move.coriolis.list.endpoints.storage                                                    \
              --name              $( ${cmd_echo} ${harddisk} | ${cmd_jq} -r '.olvm.domain' )        \
              --output            name                                                              \
          )                                                                                         \
      )

      (( _count_harddisks++ ))
    done

    # find unique sources in backend mappings and add back to the storage map
    _json_storage_map=$(                                                                            \
      json.set                                                                                      \
        --json                  ${_json_storage_map}                                                \
        --key                   .storage_mappings.backend_mappings                                  \
        --value                 "$( ${cmd_echo} ${_json_backend_map} | ${cmd_jq} -c '.backend_mappings | unique_by(.source)' )" \
    )

    # create destination environment json
    _json_destination_environment_map=$(  ${cmd_echo} ${host} | ${cmd_jq} '.coriolis.transfer.destination | del( .. | select( . == null ) )'  | ${cmd_jq} -c )
    _json_destination_environment_map=$( json.append --json ${_json_destination_environment_map} --key . --value "${_json_storage_map}" )
    _json_destination_environment_map=$( json.set --json ${_json_destination_environment_map} --key .network_map --value "${_json_network_map}" )
    
    if [[ ! -z ${_json_migration_template_password_map} ]]; then
      _json_destination_environment_map=$( json.set --json ${_json_destination_environment_map} --key .migr_template_password_map --value "${_json_migration_template_password_map}" )
    fi
    
    if [[ ! -z ${_json_migration_template_username_map} ]]; then
      _json_destination_environment_map=$( json.set --json ${_json_destination_environment_map} --key .migr_template_username_map --value "${_json_migration_template_username_map}" )
    fi

    # user scripts
    case ${_os_family} in
      linux ) _user_script=/usr/local/scripts/linux.sh ;;
      windows ) _user_script=/usr/local/scripts/windows.ps1 ;;
    esac


    # output command to screen - verbose output
    if [[ ${_verbose} == ${true} ]]; then
      >&2 ${cmd_cat} << EOF.Transfer
${cmd_coriolis}                                                                                           
  transfer                                                                                                
  create                                                                                                  

  # --destination-endpoint $( move.coriolis.list.endpoints --endpoint $( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.transfer.endpoint.destination' ) | ${cmd_jq} -r '.[-1].ID' )
  --destination-endpoint $( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.transfer.endpoint.destination' )

  --destination-environment '${_json_destination_environment_map}'
  
$( echo $_json_destination_environment_map | jq )

  # --origin-endpoint $( move.coriolis.list.endpoints --endpoint $( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.transfer.endpoint.source' ) | ${cmd_jq} -r '.[-1].ID' )
  --origin-endpoint $( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.transfer.endpoint.source' )

  --instance $(  ${cmd_echo} ${host} | ${cmd_jq} -r '.vsphere.server.datacenter' )/$(  ${cmd_echo} ${host} | ${cmd_jq} -r '.vsphere.host.folder.name' )/$(  ${cmd_echo} ${host} | ${cmd_jq} -r '.name' )

  --network-map ${_json_network_map}

  --notes "$(  ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ) - 1MC ${_BUILD}"

  --scenario ${_type}

  --source-environment $(  ${cmd_echo} ${host} | ${cmd_jq} '.coriolis.transfer.source | del( .. | select( . == null ) )' | ${cmd_jq} -c )

  --user-script-global ${_os_family}=${_user_script}

EOF.Transfer

    fi


    # # only create if no other transfer exists
    # move.coriolis.validate.transfers --name ${_name}
    # if [[ ${?} != ${exit_ok} ]]; then


      # create the transfer
      if [[ ${_dryrun} == ${false} ]]; then
        _json_output=$(                                                                                 \
          ${cmd_coriolis}                                                                               \
            transfer                                                                                    \
            create                                                                                      \
            --destination-endpoint $( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.transfer.endpoint.destination' ) \
            --destination-environment ${_json_destination_environment_map}                              \
            --format json                                                                               \
            --instance $(  ${cmd_echo} ${host} | ${cmd_jq} -r '.vsphere.server.datacenter' )/$(  ${cmd_echo} ${host} | ${cmd_jq} -r '.vsphere.host.folder.name' )/$(  ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ) \
            --network-map ${_json_network_map}                                                          \
            --notes "$(  ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ) - 1MC ${_BUILD}"                  \
            --origin-endpoint $( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.transfer.endpoint.source' ) \
            --scenario ${_type}                                                                         \
            --source-environment $(  ${cmd_echo} ${host} | ${cmd_jq} '.coriolis.transfer.source | del( .. | select( . == null ) )' | ${cmd_jq} -c ) \
            --user-script-global ${_os_family}=${_user_script}                                          \
              | ${cmd_jq} -c 
        )
   

        # write the transfer data to the host transfer
        if [[ ${?} == ${exit_ok} ]]; then
          shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] ID:$(  ${cmd_echo} ${_json_output} | ${cmd_jq} -r '.id' ), VM: ${_name}"
      
          # write transfer output to vm json
          if  ( [[ ! -z ${_json_output}     ]] ||                                                       \
                [[ ${_json_output} != "{}"  ]]                                                          \
              ) &&                                                                                      \

            [[ $( ${cmd_echo} ${_json_output} | is_json ) == ${true} ]]; then
            
            # create output directory
            [[ ! -d ${_path}/${_profile}/transfers/create/$(  ${cmd_echo} ${host} | ${cmd_jq} -r '.name' ) ]] && ${cmd_mkdir} --parents ${_path}/${_profile}/transfers/create/$(  ${cmd_echo} ${host} | ${cmd_jq} -r '.name' )
            
            # output json
            ${cmd_echo} ${_json_output} > ${_path}/${_profile}/transfers/create/$(  ${cmd_echo} ${host} | ${cmd_jq} -r '.name' )/$(  ${cmd_echo} ${_json_output} | ${cmd_jq} -r '.id' ).json
          fi

        #   # update coriolis transfer cache
        #   # coriolis.get.transfers

        fi

      else
        shell.log "${FUNCNAME}(${_profile}) - [FAILURE] "
      
      fi

    # else
    #   shell.log "${FUNCNAME}(${_profile}) - [FAILURE] Transfer Exists, VM: ${_name} Transfer: $( move.coriolis.validate.transfers --name ${_name} --output id )"

    # fi


  done

  # cleanup
  [[ -f ${_tmp_file} ]] && ${cmd_rm} -f ${_tmp_file}

  # exit
  [[ ${_error_count} != 0 ]] || _exit_code=${exit_crit} && _exit_code=${exit_ok}
  return ${_exit_code}
}