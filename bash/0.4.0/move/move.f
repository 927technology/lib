move() {
  # argument variables
  local _batch=${false}
  local _coriolis_deployment_date=
  local _coriolis_transfer_date=
  local _failed_steps=0
  local _move_filter=
  local _move_profile=
  local _olvm_cluster=
  local _olvm_data_center=
  local _olvm_storage_domain_minion=
  local _olvm_storage_domain=
  local _olvm_vlan=
  local _vsphere_update_networks=${false}
  local _vsphere_update_vms=${false}
  local _vsphere_search="regex"
  local _vsphere_type="connect"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ "${1}" != "" ]]; do
    case "${1}" in
      -b | --batch )
        _batch=${true}
      ;;
      -cdd  | --coriolis-deployment-date )
        shift
        _coriolis_deployment_date="${1}"
      ;;
      -ctd  | --coriolis-transfer-date )
        shift
        _coriolis_transfer_date="${1}"
      ;;
      -f  | --filter )
        shift
        _move_filter="${1}"
      ;;
      -oc | --olvm-cluster )
        shift
        _olvm_cluster="${1}"
      ;;
      -odc | --olvm-data-center )
        shift
        _olvm_data_center="${1}"
      ;;
      -omsd | --olvm-minion-storage-domain )
        shift
        _olvm_storage_domain_minion="${1}"
      ;;
      -osd | --olvm-storage-domain )
        shift
        _olvm_storage_domain="${1}"
      ;;
      -ov | --olvm-vlan )
        shift
        _olvm_vlan="${1}"
      ;;
      -p  | --profile )
        shift
        _move_profile="${1}"
      ;;
      -vun  | --vsphere-update-networks )
        _vsphere_update_networks=${true}
      ;;
      -vuv  | --vsphere-update-vms )
        _vsphere_update_vms=${true}
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  if  [[ ! -z ${_move_filter} ]]; then
    # set profile
    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} SETTING PROFILE
    move.set.profile --profile ${_move_profile}
    ${cmd_echo} ===============================================
    ${cmd_echo}

    # get secrets
    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} FEECHING SECRETS FROM VAULT
    move.get.secrets
    ${cmd_echo} ===============================================
    ${cmd_echo}

    # update coriolis cache
    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} UPDATING CORIOLIS CACHE
    coriolis.update.cache
    ${cmd_echo} ===============================================
    ${cmd_echo}

    # update translations cache
    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} CREATING TRANSLATION CACHE
    move.create.translations                                    \
      --profile ${_profile}
    ${cmd_echo} ===============================================
    ${cmd_echo}

    # get vsphere inventory
    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} FETCHING INVENTORY FROM VSPHERE
    if [[ ${_vsphere_update_vms} == ${true} ]]; then
      vsphere.get.vms                                           \
        --profile ${_profile}                                   \
        --search ${_filter}                                     \
        --type regex 

    else
      ${cmd_echo} SKIPPING

    fi
    ${cmd_echo} ===============================================
    ${cmd_echo}

    # get vsphere networks
    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} FETCHING NETWORKS FROM VSPHERE
    if [[ ${_vsphere_update_networks} == ${true} ]]; then
      vsphere.get.networks                                      \
        --profile ${_profile}

    else
      ${cmd_echo} SKIPPING

    fi
    ${cmd_echo} ===============================================
    ${cmd_echo}

    # create move inventory
    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} CREATING 1MC TRANSFER PROFILE
    move.create.vms                                             \
      --filter ${_move_filter}                                  \
      --profile ${_profile}
    ${cmd_echo} ===============================================
    ${cmd_echo}

    # list inventory
    ${cmd_echo} Inventory - Profile: ${_move_profile} Filter: ${_move_filter}
    ${cmd_echo} -----------------------------------------------
    move.list.vms                                               \
      --filter ${_move_filter}                                  \
      --profile ${_profile}                                     \
      --output name
    ${cmd_echo} ===============================================
    ${cmd_echo}

    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} SETTING MISSING TRANSFER KEYS

    # itterate hosts in filter and validate entries in their transfer profile
    for host in $( move.list.vms --filter ${_move_filter} --output name ); do
      # reset _failed_steps counter
      _failed_steps=0

      # set values in transfer profile based on translation
      if [[ $( move.list.translations --host ${host} --output exists ) == ${true} ]]; then
        move.set.transfers                                      \
          --host ${host}                                        \
          --key .coriolis.transfer.destination.cluster          \
          --profile ${_move_profile}                            \
          --value $(                                            \
            move.list.translations                              \
              --host ${host}                                    \
              --output olvm_cluster                             \
              --profile ${_profile}                             \
            )                                                   \
          || { (( _error_count++ )); (( _failed_steps++ )); }

        move.set.transfers                                      \
          --host ${host}                                        \
          --key .coriolis.transfer.destination.migr_minion_storage_domain \
          --profile ${_move_profile}                            \
          --value $(                                            \
            move.list.translations                              \
              --host ${host}                                    \
              --output olvm_storage_domain_minion               \
              --profile ${_profile}                             \
            )                                                   \
          || { (( _error_count++ )); (( _failed_steps++ )); }

        for i in {0..9}; do
          move.set.transfers                                    \
            --host ${host}                                      \
            --key .harddisks[${i}].olvm.domain                  \
            --profile ${_move_profile}                          \
            --value $(                                          \
              move.list.translations                            \
                --host ${host}                                  \
                --output olvm_storage_domain                    \
                --profile ${_profile}                           \
              )                                                 \
            || { (( _error_count++ )); (( _failed_steps++ )); }
        
        done

        move.set.transfers                                      \
          --host ${host}                                        \
          --key .networkadapters[0].olvm.datacenter             \
          --profile ${_move_profile}                            \
          --value $(                                            \
            move.list.translations                              \
              --host ${host}                                    \
              --output olvm_data_center                         \
              --profile ${_move_profile}                        \
            )                                                   \
          || { (( _error_count++ )); (( _failed_steps++ )); }

        move.set.transfers                                      \
          --host ${host}                                        \
          --key .networkadapters[0].olvm.vlan                   \
          --profile ${_move_profile}                            \
          --value $(                                            \
            move.list.translations                              \
              --host ${host}                                    \
              --output olvm_vlan                                \
              --profile ${_move_profile}                        \
            )                                                   \
          || { (( _error_count++ )); (( _failed_steps++ )); }

        if [[ $( move.list.translations --host ${host} --output coriolis_deployment_enable ) == ${true} ]]; then
          move.set.transfers                                    \
            --host ${host}                                      \
            --key .move.coriolis.deployment.date                \
            --profile ${_move_profile}                          \
            --value $(                                          \
              move.list.translations                            \
                --host ${host}                                  \
                --output coriolis_deployment_date               \
                --profile ${_move_profile}                      \
              )                                                 \
            || { (( _error_count++ )); (( _failed_steps++ )); }

        fi

        move.set.transfers                                      \
          --host ${host}                                        \
          --key .move.coriolis.deployment.enable                \
          --profile ${_move_profile}                            \
          --value $(                                            \
            move.list.translations                              \
              --host ${host}                                    \
              --output coriolis_deployment_enable               \
              --profile ${_move_profile}                        \
            )                                                   \
          || { (( _error_count++ )); (( _failed_steps++ )); }
        
        if [[ $( move.list.translations --host ${host} --output coriolis_transfer_enable ) == ${true} ]]; then
          move.set.transfers                                    \
            --host ${host}                                      \
            --key .move.coriolis.transfer.date                  \
            --profile ${_move_profile}                          \
            --value $(                                          \
              move.list.translations                            \
                --host ${host}                                  \
                --output coriolis_transfer_date                 \
                --profile ${_move_profile}                      \
              )                                                 \
            || { (( _error_count++ )); (( _failed_steps++ )); }
        
        fi
        move.set.transfers --host ${host}   --key .move.coriolis.transfer.enable                            --profile ${_move_profile} --value $( move.list.translations --host ${host} --output coriolis_transfer_enable   ) || { (( _error_count++ )); (( _failed_steps++ )); }

      # set values in transfer profile based on arguments
      else
        [[ ! -z ${_olvm_cluster}                ]]  && { move.set.transfers --filter ${_move_filter} --key .coriolis.transfer.destination.cluster                     --profile ${_move_profile} --value ${_olvm_cluster}               || (( _error_count++ )); (( _failed_steps++ )); }
        for i in {0..9}; do
          [[ ! -z ${_olvm_storage_domain}       ]]  && { move.set.transfers --filter ${_move_filter} --key .harddisks[${i}].olvm.domain                               --profile ${_move_profile} --value ${_olvm_storage_domain}        || (( _error_count++ )); (( _failed_steps++ )); }
        
        done
        [[ ! -z ${_olvm_data_center}            ]]  && { move.set.transfers --filter ${_move_filter} --key .networkadapters[0].olvm.datacenter                        --profile ${_move_profile} --value ${_olvm_data_center}           || (( _error_count++ )); (( _failed_steps++ )); }
        [[ ! -z ${_olvm_vlan}                   ]]  && { move.set.transfers --filter ${_move_filter} --key .networkadapters[0].olvm.vlan                              --profile ${_move_profile} --value ${_olvm_vlan}                  || (( _error_count++ )); (( _failed_steps++ )); }
        [[ ! -z ${_olvm_storage_domain_minion}  ]]  && { move.set.transfers --filter ${_move_filter} --key .coriolis.transfer.destination.migr_minion_storage_domain  --profile ${_move_profile} --value ${_olvm_storage_domain_minion} || (( _error_count++ )); (( _failed_steps++ )); }
        [[ ! -z ${_coriolis_deployment_date}    ]]  && { move.set.transfers --filter ${_move_filter} --key .move.coriolis.deployment.date                             --profile ${_move_profile} --value ${_coriolis_deployment_date}   || (( _error_count++ )); (( _failed_steps++ )); }
        [[ ! -z ${_coriolis_deployment_date}    ]]  && { move.set.transfers --filter ${_move_filter} --key .move.coriolis.deployment.enable                           --profile ${_move_profile} --value ${true}                        || (( _error_count++ )); (( _failed_steps++ )); }
        [[ ! -z ${_coriolis_transfer_date}      ]]  && { move.set.transfers --filter ${_move_filter} --key .move.coriolis.transfer.date                               --profile ${_move_profile} --value ${_coriolis_transfer_date}     || (( _error_count++ )); (( _failed_steps++ )); }
        [[ ! -z ${_coriolis_transfer_date}      ]]  && { move.set.transfers --filter ${_move_filter} --key .move.coriolis.transfer.enable                             --profile ${_move_profile} --value ${true}                        || (( _error_count++ )); (( _failed_steps++ )); }
      
      fi
 
    done
    ${cmd_echo} ===============================================
    ${cmd_echo}

    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} VALIDATING 1MC TRNASFER PROFILES
    move.validate.transfers                                     \
      --filter ${_move_filter}                                  \
      --profile ${_profile}                                     \
      --verbose                                                 \
    || (( _failed_steps++ ))

    ${cmd_echo} ===============================================
    ${cmd_echo}

    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} CREATING CORIOLIS TRANSFERS
    # only create transfers if no failed steps
    if [[ ${_failed_steps} == 0 ]]; then
      move.coriolis.create.transfers                            \
        --filter ${_move_filter}                                \
        --profile ${_profile}                                   \
      || (( _failed_steps++ ))
    
    else
      ${cmd_echo} Failed Validations: VM: ${host}

    fi
    ${cmd_echo} ===============================================
    ${cmd_echo}

    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} CREATING CORIOLIS TRANSFER SCHEDULES
    # only create transfer schedule if no failed steps
    if [[ ${_failed_steps} == 0 ]]; then
      move.coriolis.create.transfers.schedule                   \
        --filter ${_move_filter}                                \
        --profile ${_profile}                                   \
      || (( _failed_steps++ ))
    
    else
      ${cmd_echo} Failed Validations: VM: ${host}
    
    fi
    ${cmd_echo} ===============================================
    ${cmd_echo}

    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} CREATING CORIOLIS DEPLOYMENT SCHEDULES
    # only create deployment schedule if no failed steps
    if [[ ${_failed_steps} == 0 ]]; then
      move.coriolis.create.deployments.schedule                 \
        --filter ${_move_filter}                                \
        --profile ${_profile}                                   \
      || (( _failed_steps++ ))
    
    else
      ${cmd_echo} Failed Validations: VM: ${host}

    fi

    ${cmd_echo} ===============================================
    ${cmd_echo}

    # update coriolis cache
    ${cmd_echo} -----------------------------------------------
    ${cmd_echo} UPDATING CORIOLIS CACHE
    coriolis.update.cache                                       \
      --profile ${_profile}

    ${cmd_echo} ===============================================
    ${cmd_echo}


    if [[ ${_batch} == ${true} ]]; then
      _batch=10
      _count=0
      for host in $( move.list.transfers --filter CoriolisWin --output name --profile ${_profile} ); do 
        ${cmd_echo} ${host}
        
        ${cmd_coriolis}                                         \
          transfer                                              \
          execute                                               \
          $(                                                    \
            move.list.transfers.created                         \
              --name ${host}                                    \
              --output id                                       \
          )               
        
        (( _count++ ))
        
        if [[ $_count -ge ${_batch} ]]; then
          ${cmd_echo} end batch
          sleep 1200
          _count=0
        fi
      done
    fi

  else
    ${cmd_echo} "rut-ro"

  fi
}


  # move                                            \
  #   --coriolis-deployment-date "12/31/2026 04:00" \
  #   --coriolis-transfer-date "12/25/2026 04:00"   \
  #   --filter CoriolisWin-[01][6-7]                \
  #   --olvm-cluster LS1KVMGP02                     \
  #   --olvm-data-center LS1GP01                    \
  #   --olvm-minion-storage-domain LS1SDGP0201      \
  #   --olvm-storage-domain LS1SDGP0201             \
  #   --olvm-vlan 150                               \
  #   --profile lab                                 \
  #   --vsphere-update-vms                          \
  #   --vsphere-update-networks
