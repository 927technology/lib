move.validate.transfers() {
  # local variables
  local _output=
  local _path=~move/move
  declare -a local _validations=( \
    .coriolis_transfer_destination_endpoint \
    .coriolis_transfer_destination_cluster \
    .coriolis_transfer_destination_delete_protected \
    .coriolis_transfer_destination_leave_migrated_vms_off \
    .coriolis_transfer_destination_migr_blank_template \
    .coriolis_transfer_destination_migr_minion_cluster \
    .coriolis_transfer_destination_migr_minion_storage_domain \
    .coriolis_transfer_destination_network_map \
    .coriolis_transfer_destination_optimized_for \
    .coriolis_transfer_destination_os_release \
    .coriolis_transfer_destination_set_dhcp \
    .coriolis_transfer_endpoint \
    .coriolis_transfer_source_endpoint \
    .harddisks \
    .networkadapters \
    .coriolis_transfer_source_automatically_enable_cbt
  )
  local _value=

  # argument variables
  local _filter=
  local _name=
  local _type=live_migration
  local _pretty=${false}
  local _verbose=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _tmp_file=$( ${cmd_mktemp} )
  local validation=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -h | --host | -n | --name )
        shift
        _name=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -v | --verbose )
        shift
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && exit ${exit_crit}

  # create transfer temp file
  if    [[ ! -z ${_name} ]]; then
    move.list.transfers --host ${_name} --profile ${_profile} | ${cmd_jq} -c > ${_tmp_file}
    shell.log "${FUNCNAME}(${_profile}) - [WRITING] File: ${_tmp_file}"
    ${cmd_echo} >&2
    
  elif  [[ ! -z ${_filter} ]]; then
    move.list.transfers --filter ${_filter} --profile ${_profile} | ${cmd_jq} -c > ${_tmp_file}
    shell.log "${FUNCNAME}(${_profile}) - [WRITING] File: ${_tmp_file}"
    ${cmd_echo} >&2

  else
    return ${exit_crit}
  
  fi

  # itterate transfers
  for host in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -r 'sort_by( .name ) | .[].name' ); do
    ${cmd_echo} ${host} \(${_profile}\) >&2
    ${cmd_echo} ========================================== >&2
    for validation in $( ${cmd_echo} ${_validations[@]} | ${cmd_sed} 's/\ /\n/g' ); do
      _output=
      _output="$( move.validate.key${validation} --name ${host} --profile ${_profile} 2>&1 )"
      if  [[ ${?} != ${exit_ok}   ]]; then
        # ${cmd_echo} "${_output}" | ${cmd_awk} -F" - " '{print $NF}' >&2
        >&2 ${cmd_echo} [FAILURE] KEY: ${validation}
        >&2 ${cmd_echo} "${_output}"  
        >&2 ${cmd_echo}

        (( _error_count++ ))

      else
        >&2 ${cmd_echo} [SUCCESS] KEY: ${validation}
        >&2 ${cmd_echo}

      fi

    done



    [[ ${_error_count} == 0 ]] && ${cmd_echo} Validations Passed >&2



    ${cmd_echo} ------------------------------------------ >&2
    ${cmd_echo} >&2

  done
    
  # cleanup
  [[ -f ${_tmp_file} ]] && { shell.log "${FUNCNAME}(${_profile}) - [DELETING] File: ${_tmp_file}"; ${cmd_rm} --force ${_tmp_file}; }

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}