move.create.vms() {
  # local variables
  local _count_harddisks=0
  local _count_networkadapters=0
  local _json="{}"
  local _json_transfer="{}"
  local _json_hosts=
  local _osfamily=
  local _json_migr_template_map="{}"
  local _json_migr_template_username_map="{}"
  local _json_migr_template_password_map="{}"
  local _json_osfamily="{}"
  local _osfamily_distro=
  local _osfamily_version_major=
  local _osfamily_version_minor=
  local _path_vsphere=~move/vsphere
  local _path_move=~move/move
  local _tmp_file=$( ${cmd_mktemp} )

  # argument variables
  local _filter=
  local _name=
  local _profile=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local host=
  local harddisk=
  local networkadapter=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter="${1}"
      ;;
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;      
      -p | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}

  ${cmd_mkdir} -p ${_path_move}/${_profile}/transfers
  ${cmd_mkdir} -p ${_path_move}/${_profile}/transfers/vms
  
  # clean up destinations
  ${cmd_rm} --force ${_path_move}/${_profile}/transfers/vms/*

  if    [[ ! -z ${_name} ]] && \
        [[ -d ${_path_vsphere}/${_profile}/vms ]] &&                                            \
        [[ -d ${_path_move}/${_profile}/transfers ]] &&                                         \
        [[ -d ${_path_move}/${_profile}/transfers/vms ]]; then
    move.vsphere.list.vms --name ${_name} --profile ${_profile} > "${_tmp_file}"

  elif  [[ ! -z ${_filter} ]] && \
        [[ -d ${_path_vsphere}/${_profile}/vms ]] &&                                            \
        [[ -d ${_path_move}/${_profile}/transfers ]] &&                                         \
        [[ -d ${_path_move}/${_profile}/transfers/vms ]]; then
    move.vsphere.list.vms --filter ${_filter} --profile ${_profile} > "${_tmp_file}"

  else
    move.vsphere.list.vms --profile ${_profile} > "${_tmp_file}"

  fi

  # create configs
  for host in $( ${cmd_cat} "${_tmp_file}" | ${cmd_jq} -c '.[]' ); do
    # zero loop variables
    _json="{}"
    _json_transfer="{}"
    _osfamily=
    _json_migr_template_map="{}"
    _json_osfamily="{}"
    _osfamily_distro=
    _osfamily_version_major=

    # name
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .name                                                                                 \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -r .Name )                                     \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .name                                                                                 \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -r '.Name' )                                   \
    )

    # transfer source and destination
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.endpoint.source                                                    \
        --value $( ${cmd_echo} ${host} | ${cmd_jq} -r '.coriolis.vsphere.endpoint' )                \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.endpoint.destination                                               \
        --value $( move.coriolis.list.endpoints | jq -r '[ .[] | select( .Type == "olvm" ) ] | if( . | length > 1 ) then null else .[0].Name end' ) \                                                                                \
    )

    # enable    
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .move.coriolis.enable                                                                 \
        --value 0                                                                                   \
    )

    # date
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .move.coriolis.execution.date                                                         \
        --value null                                                                                \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .move.coriolis.execution.enable                                                       \
        --value 0                                                                                   \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .move.coriolis.deployment.date                                                        \
        --value null                                                                                \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .move.coriolis.deployment.enable                                                      \
        --value 0                                                                                   \
    )


    # migration destination settings
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.cluster                                                \
        --value null                                                                                \
    )
    ## this value must be boolean true or false not 1 or 0
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.delete_protected                                       \
        --value false                                                                               \
    )
    ## this value must be boolean true or false not 1 or 0
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.leave_migrated_vms_off                                 \
        --value false                                                                               \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.migr_blank_template                                    \
        --value "Blank"                                                                             \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.migr_minion_cluster                                    \
        --value null                                                                                \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.migr_minion_storage_domain                             \
        --value null                                                                                \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.network_map                                            \
        --value null                                                                                \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.optimized_for                                          \
        --value "server"                                                                            \
    )
    

    # get os family
    _json_osfamily=$( ${cmd_cat} /usr/local/etc/coriolis/osfamily.json  | ${cmd_jq} -c '[ .osfamily[ [ .osfamily[].vsphere | any(. =="'"$( ${cmd_echo} ${host} | ${cmd_jq} -r '.GuestOS' )"'") ] | index(true) ] ][0]' )
    _osfamily=$( ${cmd_echo} ${_json_osfamily} | ${cmd_jq} -r '.family' )
    _osfamily_distro=$( ${cmd_echo} ${_json_osfamily} | ${cmd_jq} -r '.distro' )
    _osfamily_version_major=$( ${cmd_echo} ${_json_osfamily} | ${cmd_jq} -r '.version.major' )
    
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.os_release                                             \
        --value $( ${cmd_echo} ${_json_osfamily} | ${cmd_jq} '.olvm' )                              \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .move.coriolis.transfer.destination.os.olvm                                           \
        --value $( ${cmd_echo} ${_json_osfamily} | ${cmd_jq} '.olvm' )                              \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .move.coriolis.transfer.destination.os.coriolis                                       \
        --value $( ${cmd_echo} ${_json_osfamily} | ${cmd_jq} '.coriolis' )                          \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .move.coriolis.transfer.destination.os.family                                         \
        --value ${_osfamily}                                                                        \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .move.coriolis.transfer.destination.os.vsphere                                        \
        --value $( ${cmd_echo} ${_json_osfamily} | ${cmd_jq} '.GuestOS' )                           \
    )


    # migr_template_map
    # migr_template_password_map
    # migr_template_username_map
    # windows_virtio_zip_url
    case ${_osfamily} in 
      linux )
        # _json_migr_template_map=$( 
        #   json.set 
        #     --json "${_json_migr_template_map}" 
        #     --key linux 
        #     --value $( 
        #       move.coriolis.list.endpoints.destination.options  
        #         --type minion 
        #         --name "minion-${_osfamily_distro}_${_osfamily_version_major}" 
        #         --output id
        #     )
        # ) 

         _json_migr_template_map=$(                                                                 \
          json.set                                                                                  \
            --json "${_json_migr_template_map}"                                                     \
            --key ".linux"                                                                          \
            --value $(                                                                              \
              move.coriolis.list.endpoints.destination.options                                      \
                --type minion                                                                       \
                --name OL7U9minion4                                                                 \
                --output id                                                                         \
            )                                                                                       \
        )    
      ;;
      windows )
        # _json_migr_template_map=$( 
        #   json.set 
        #     --json "${_json_migr_template_map}" 
        #     --key linux 
        #     --value "minion-ol_8"
        # )    
        # _json_migr_template_map=$( 
        #   json.set 
        #     --json "${_json_migr_template_map}" 
        #     --key linux 
        #     --value $( 
        #       move.coriolis.list.endpoints.destination.options  
        #         --type minion 
        #         --name "minion-${_osfamily_distro}_${_osfamily_version_major}" 
        #         --output id
        #     )
        # )  

        _json_migr_template_map=$(                                                                  \
          json.set                                                                                  \
            --json "${_json_migr_template_map}"                                                     \
            --key ".linux"                                                                          \
            --value $(                                                                              \
              move.coriolis.list.endpoints.destination.options                                      \
                --type minion                                                                       \
                --name OL8U10minion2                                                                \
                --output id                                                                         \
            )                                                                                       \
        )    
        _json_migr_template_map=$(                                                                  \
          json.set                                                                                  \
            --json "${_json_migr_template_map}"                                                     \
            --key ".windows"                                                                        \
            --value $(                                                                              \
              move.coriolis.list.endpoints.destination.options                                      \
                --type minion                                                                       \
                --name OVIRT_WIN2019minion2                                                         \
                --output id                                                                         \
            )                                                                                       \
        ) 

        _json_migr_template_password_map=$(                                                         \
          json.set                                                                                  \
            --json "${_json_migr_template_password_map}"                                            \
            --key ".windows"                                                                        \
            --value $( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '[ .[] | select( .name =="'"${_profile}"'" ) ][0].coriolis[0].migr_map[] | select(( .label | ascii_downcase ) == "windows").password' ) \
        )

        _json_migr_template_username_map=$(                                                         \
          json.set                                                                                  \
            --json ${_json_migr_template_username_map}                                              \
            --key ".windows"                                                                        \
            --value $( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '[ .[] | select( .name =="'"${_profile}"'" ) ][0].coriolis[0].migr_map[] | select(( .label | ascii_downcase ) == "windows").username' ) \
        )
        
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .coriolis.transfer.destination.migr_template_password_map                         \
            --value "${_json_migr_template_password_map}"                                           \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .coriolis.transfer.destination.migr_template_username_map                         \
            --value "${_json_migr_template_username_map}"                                           \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .coriolis.transfer.destination.windows_virtio_zip_url                             \
            --value "$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '[ .[] | select( .name =="'"${_profile}"'" ) ][0].coriolis[0].windows_virtio_zip_url' )" \
        )
      ;;
    esac 

    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.migr_template_map                                      \
        --value "${_json_migr_template_map}"                                                        \
    )  
    

    # destination
    ## this value must be boolean true or false not 1 or 0
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key ".coriolis.transfer.destination.set_dhcp"                                             \
        --value false                                                                               \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.storage_mappings                                       \
        --value null                                                                                \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.destination.vm_pool                                                \
        --value null                                                                                \
    )


    # migration source settings
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.source.vixdisklib_compatibility_version                            \
        --value \"8.0\"                                                                             \
    )
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .coriolis.transfer.source.automatically_enable_cbt                                    \
        --value true                                                                                \
    )


    # vm vsphere settings
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.host.datastoreidlist                                                         \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.DatastoreIdList'  )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.host.corespersocket                                                          \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.CoresPerSocket'   )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.host.guestos                                                                 \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.GuestOS'          )                       \   
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.host.id                                                                      \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.ID'               )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.host.folder.name                                                             \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.FolderName'       )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.host.folder.id                                                               \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.FolderId'         )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.host.memorymb                                                                \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq}    '.MemoryMB'         )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.host.numcpu                                                                  \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.NumCpu'           )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.host.powerstate                                                              \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq}    '.PowerState'       )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.server.name                                                                  \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.VSphere'          )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.server.cluster                                                               \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.Cluster'          )                       \
    )
    _json=$(                                                                                        \
      json.set                                                                                      \
        --json "${_json}"                                                                           \
        --key .vsphere.server.datacenter                                                            \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.DataCenter'       )                       \
    )


    # migration vsphere settings - copy from vm vsphere settings
    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .vsphere                                                                              \
        --value $( ${cmd_echo} "${_json}" | ${cmd_jq} -c '.vsphere' )                               \
    )


    # parse hard disks
    if [[ $( ${cmd_echo} "${host}" | ${cmd_jq} '. | if( .HardDisks != null ) then '${true}' else '${false}' end' ) == ${true} ]]; then
      # has configured hard disks
      if [[ $( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks | if( type=="array" ) then '${true}' else '${false}' end' ) == ${false} ]]; then
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .harddisks[0].capacitygb                                                          \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.CapacityGB' )                  \
        )
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .harddisks[0].filename                                                            \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.FileName' )                    \
          )
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .harddisks[0].name                                                                \
            --value $(${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.Name' )                         \
          )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .harddisks[0].vsphere.capacitygb                                                  \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.CapacityGB' )                  \
        )
        
        # no hard disks configured
        if [[ $( ${cmd_echo} ${host} | ${cmd_jq} 'if (.HardDisks == null ) then '${true}' else '${false}' end' ) == ${true} ]]; then
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks                                                                      \
              --value "[]" )                                                                        \

        else
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[0].id.name                                                           \
              --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.ID | split("/")[0]' )        \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[0].id.index                                                          \
              --value "$( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.ID | split("/")[1]' )"      \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[0].vsphere.filename.full                                             \
              --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.FileName' )                  \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[0].vsphere.filename.label                                            \
              --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.FileName | split("] ")[0]' | ${cmd_sed} 's/\[//g' ) \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[0].vsphere.filename.path                                             \
              --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.FileName | split("] ")[1]' ) \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[0].vsphere.name                                                      \
              --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.HardDisks.Name' )                      \
          )
          # _json_transfer=$( 
          #   json.set                                                                                \
          #     --json "${_json_transfer}"                                                            \
          #     --key .harddisks[0].olvm.datacenter                                                   \
          #     --value null                                                                          \
          # )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[0].olvm.domain                                                       \
              --value null                                                                          \
          )
      
        fi
      else

        # reset loop variable
        _count_harddisks=0

        for harddisk in $( ${cmd_echo} ${host} | ${cmd_jq} -c '.HardDisks[]' ); do
          _json=$(                                                                                  \
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .harddisks[${_count_harddisks}].capacitygb                                      \
              --value $( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.CapacityGB' )                      \
          )
          _json=$(                                                                                  \
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .harddisks[${_count_harddisks}].filename                                        \
              --value $( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.FileName' )                        \
          )
          _json=$(                                                                                  \
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .harddisks[${_count_harddisks}].name                                            \
              --value $( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.Name' )                            \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[${_count_harddisks}].vsphere.capacitygb                              \
              --value $( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.CapacityGB' )                      \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[${_count_harddisks}].id.name                                         \
              --value $( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.ID | split("/")[0]' )              \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[${_count_harddisks}].id.index                                        \
              --value "$( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.ID | split("/")[1]' )"            \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[${_count_harddisks}].vsphere.filename.full                           \
              --value $( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.FileName' )                        \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[${_count_harddisks}].vsphere.filename.label                          \
              --value $( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.FileName | split("] ")[0]' | ${cmd_sed} 's/\[//g' ) \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[${_count_harddisks}].vsphere.filename.path                           \
              --value $( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.FileName | split("] ")[1]' )       \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[${_count_harddisks}].vsphere.name                                    \
              --value $( ${cmd_echo} "${harddisk}" | ${cmd_jq} '.Name' )                            \
          )
          # _json_transfer=$(                                                                         \
          #   json.set                                                                                \
          #     --json "${_json_transfer}"                                                            \
          #     --key .harddisks[${_count_harddisks}].olvm.datacenter                                 \
          #     --value null                                                                          \
          #   )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .harddisks[${_count_harddisks}].olvm.domain                                     \
              --value null                                                                          \
          )

          (( _count_harddisks++ ))
        done
      fi

    else
      # no configured hard disks
      _json=$(                                                                                      \
        json.set                                                                                    \
          --json "${_json}"                                                                         \
          --key .harddisks                                                                          \
          --value "[]"                                                                              \
      )
    fi


    # parse network adapters
    if [[ $( ${cmd_echo} "${host}" | ${cmd_jq} '. | if( .NetworkAdapters != null ) then '${true}' else '${false}' end' ) == ${true} ]]; then
      # has configured network adapters
      if [[ $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters | if(( type=="array" ) and ( . | length ) > 0 ) then '${true}' else '${false}' end' ) == ${false} ]]; then
        # single network adapter
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .networkadapters[0].address                                                       \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} 'try( .GuestIP[0] )' )                     \
        )
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .networkadapters[0].networkname                                                   \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.NetworkName' )           \
        )
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .networkadapters[0].macaddress                                                    \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.MacAddress' )            \
          )
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .networkadapters[0].name                                                          \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.Name' )                  \
        )
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .networkadapters[0].type                                                          \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.Type' )                  \
        )
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .networkadapters[0].wakeonlan                                                     \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.WakeOnLan' )             \
        )
        # _json=$(                                                                                    \
        #   json.set                                                                                  \
        #     --json "${_json}"                                                                       \
        #     --key .networkadapters[0].vlan                                                          \
        #     --value $( ${cmd_echo} "${host}" | ${cmd_jq} -r 'try( if( .NetworkAdapters.NetworkName | split("-") | length == 6 ) then .NetworkAdapters.NetworkName | split("-")[-2] else null end )' ) \
        # )
        _json=$(                                                                                    \
          json.set                                                                                  \
            --json "${_json}"                                                                       \
            --key .networkadapters[0].vlan                                                          \
            --value null                                                                            \
        )


        # migrtion vmware settings
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].address                                                       \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} 'try( .GuestIP[0] )' )                     \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].vsphere.networkname                                           \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.NetworkName' )           \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].vsphere.macaddress                                            \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.MacAddress' )            \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].vsphere.name                                                  \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.Name' )                  \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].vsphere.type                                                  \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.Type' )                  \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].vsphere.wakeonlan                                             \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.WakeOnLan' )             \
        )
        # _json_transfer=$(                                                                           \
        #   json.set                                                                                  \
        #     --json "${_json_transfer}"                                                              \
        #     --key .networkadapters[0].vsphere.vlan                                                 \
        #     --value $( ${cmd_echo} "${host}" | ${cmd_jq} -r 'try( if( .NetworkAdapters.NetworkName | split("-") | length == 6 ) then .NetworkAdapters.NetworkName | split("-")[-2] else null end )' ) \
        # )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].vsphere.vlan                                                  \
            --value null                                                                            \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].vsphere.host                                                  \
            --value null                                                                            \
        )


        # migration olvm settings
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].olvm.datacenter                                               \
            --value null                                                                            \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].olvm.macaddress                                               \
            --value $( ${cmd_echo} "${host}" | ${cmd_jq} '.NetworkAdapters.MacAddress' )            \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].olvm.name                                                     \
            --value null                                                                            \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].olvm.networkname                                              \
            --value null                                                                            \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].olvm.type                                                     \
            --value null                                                                            \
        )
        # _json_transfer=$( 
        #   json.set                                                                                  \
        #     --json "${_json_transfer}"                                                              \
        #     --key .networkadapters[0].olvm.vlan                                                    \
        #     --value $( ${cmd_echo} "${host}" | ${cmd_jq} -r 'try( if( .NetworkAdapters.NetworkName | split("-") | length == 6 ) then .NetworkAdapters.NetworkName | split("-")[-2] else null end )' ) \
        # )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].olvm.vlan                                                     \
            --value null                                                                            \
        )
        _json_transfer=$(                                                                           \
          json.set                                                                                  \
            --json "${_json_transfer}"                                                              \
            --key .networkadapters[0].olvm.wakeonlan                                                \
            --value null                                                                            \
        )

      else
        # multiple network adapters   
        _count_networkadapters=0

        for networkadapter in $( ${cmd_echo} ${host} | ${cmd_jq} -c '.NetworkAdapters[]' ); do
          _json=$( 
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .networkadapters[${_count_networkadapters}].address                             \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} 'try( .GuestIP['${_count_networkadapters}'] )' ) \
          )
          _json=$(                                                                                  \
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .networkadapters[${_count_networkadapters}].networkname                         \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.NetworkName' )               \
          )
          _json=$(                                                                                  \
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .networkadapters[${_count_networkadapters}].macaddress                          \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.MacAddress' )                \
          )
          _json=$(                                                                                  \
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .networkadapters[${_count_networkadapters}].name                                \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.Name' )                      \
          )
          _json=$(                                                                                  \
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .networkadapters[${_count_networkadapters}].type                                \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.Type' )                      \
          )
          _json=$(                                                                                  \
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .networkadapters[${_count_networkadapters}].wakeonlan                           \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.WakeOnLan' )                 \
          )
          # _json=$(                                                                                  \
          #   json.set                                                                                \
          #     --json "${_json}"                                                                     \
          #     --key .networkadapters[${_count_networkadapters}].vlan                                \
          #     --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} -r 'try( if( .NetworkName | split("-") | length == 6 ) then .NetworkName | split("-")[-2] else null end )' ) \
          # )
          _json=$(                                                                                  \
            json.set                                                                                \
              --json "${_json}"                                                                     \
              --key .networkadapters[${_count_networkadapters}].vlan                                \
              --value null                                                                          \
          )

          # migrtion vmware settings
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].address                             \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} 'try( .GuestIP['${_count_networkadapters}'] )' ) \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].vsphere.networkname                 \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.NetworkAdapters.NetworkName' ) \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].vsphere.macaddress                  \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.NetworkAdapters.MacAddress' ) \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].vsphere.name                        \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.NetworkAdapters.Name' )      \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].vsphere.type                        \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.NetworkAdapters.Type' )      \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].vsphere.wakeonlan                   \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.NetworkAdapters.WakeOnLan' ) \
          )
          # _json_transfer=$(                                                                         \
          #   json.set                                                                                \
          #     --json "${_json_transfer}"                                                            \
          #     --key .networkadapters[${_count_networkadapters}].vsphere.vlan                       \
          #     --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} -r 'try( if( .NetworkAdapters.NetworkName | split("-") | length == 6 ) then .NetworkAdapters.NetworkName | split("-")[-2] else null end )' ) \
          # )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].vsphere.vlan                        \
              --value null                                                                          \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].vsphere.host                        \
              --value null                                                                          \
          )

          # migration olvm settings
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].olvm.networkname                    \
              --value null                                                                          \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].olvm.macaddress                     \
              --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} '.NetworkAdapters.MacAddress' ) \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].olvm.name                           \
              --value null                                                                          \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].olvm.type                           \
              --value null                                                                          \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].olvm.wakeonlan                      \
              --value null                                                                          \
          )
          # _json_transfer=$(                                                                         \
          #   json.set                                                                                \
          #     --json "${_json_transfer}"                                                            \
          #     --key .networkadapters[${_count_networkadapters}].olvm.vlan                           \
          #     --value $( ${cmd_echo} "${networkadapter}" | ${cmd_jq} -r 'try( if( .NetworkAdapters.NetworkName | split("-") | length == 6 ) then .NetworkAdapters.NetworkName | split("-")[-2] else null end )' ) \
          # )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].olvm.vlan                           \
              -value null                                                                           \
          )
          _json_transfer=$(                                                                         \
            json.set                                                                                \
              --json "${_json_transfer}"                                                            \
              --key .networkadapters[${_count_networkadapters}].olvm.host                           \
              --value null                                                                          \
          )

          (( _count_networkadapters++ ))
        done

      fi  
      
    else
      # no configured network adapters
      _json=$(                                                                                      \
        json.set                                                                                    \
          --json "${_json}"                                                                         \
          --key .networkadapters                                                                    \
          --value "[]"                                                                              \
      )
    fi

    _json_transfer=$(                                                                               \
      json.set                                                                                      \
        --json "${_json_transfer}"                                                                  \
        --key .numcpu                                                                               \
        --value $( ${cmd_echo} "${host}" | ${cmd_jq} -c '.NumCpu' )                                 \
    )

    # ${_path_move}/transfers/vms
    shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] ID: $( ${cmd_echo} "${host}" | ${cmd_jq} -r '.ID' ), VM: $( ${cmd_echo} "${host}" | ${cmd_jq} -r '.Name' ), Type: VM, Family: ${_osfamily}"
    ${cmd_echo} "${_json}" | ${cmd_jq} > ${_path_move}/${_profile}/transfers/vms/$( ${cmd_echo} "${host}" | ${cmd_jq} -r '.ID' ).json

    # create name based simlink to id
    ${cmd_ln} -fs $( ${cmd_echo} "${host}" | ${cmd_jq} -r '.ID' ).json ${_path_move}/${_profile}/transfers/vms/$( ${cmd_echo} "${host}" | ${cmd_jq} -r '.Name' )


    # write ${_path_move}/transfers
    if [[ ! -f ${_path_move}/${_profile}/transfers/$( ${cmd_echo} "${host}" | ${cmd_jq} -r '.ID' ).json ]]; then
      shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] ID: $( ${cmd_echo} "${host}" | ${cmd_jq} -r '.ID' ), VM: $( ${cmd_echo} "${host}" | ${cmd_jq} -r '.Name' ), Type: Transfer, Family: ${_osfamily}"
      ${cmd_echo} "${_json_transfer}" | ${cmd_jq} > ${_path_move}/${_profile}/transfers/$( ${cmd_echo} "${host}" | ${cmd_jq} -r '.ID' ).json
    
      # create name based simlink to id
      ${cmd_ln} -fs $( ${cmd_echo} "${host}" | ${cmd_jq} -r '.ID' ).json ${_path_move}/${_profile}/transfers/$( ${cmd_echo} "${host}" | ${cmd_jq} -r '.Name' )
    
    fi
  done

  _exit_string="${_json}"

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok} 

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"
  
  [[ -f "${_tmp_file}" ]] && ${cmd_rm} -f "${_tmp_file}"
  
  return ${_exit_code}
}