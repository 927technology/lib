move.list.transfers.created() {
  # local variables
  local _tmp_file=
  local _path=~move/move

  # argument variables
  local _latest=${false}
  local _name=
  local _output=
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host | -n | --name )
        shift
        _name=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -i | --id )
        # held over from legacy (depricated)
        output=id
      ;;
      -l | --latest )
        _latest=${true}
      ;;
      -o | --output )
        shift
        _output=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}

  _tmp_file=$( ${cmd_mktemp} )
  shell.log "${FUNCNAME}(${_profile}) - [CREATING] Temp file ${_tmp_file}"


  if  [[ ! -z  ${_name} ]]    && \
      [[ -d ${_path}/${_profile}/transfers/create/${_name} ]]; then
    if [[ ${_latest} == ${true} ]]; then
      ${cmd_cat} ${_path}/${_profile}/transfers/create/${_name}/*.json 2>/dev/null | ${cmd_jq} -s | ${cmd_jq} '. | sort_by( .created ) | .[-1]' > ${_tmp_file} 

    else
      ${cmd_cat} ${_path}/${_profile}/transfers/create/${_name}/*.json 2>/dev/null | ${cmd_jq} -s | ${cmd_jq} '. | sort_by( .created ) | .[]' > ${_tmp_file} 

    fi

  else
    _exit_code=${exit_crit}

  fi

  if [[ ! -z ${_output} ]]; then
    for transfer in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c ); do
      case ${_output} in
        id                                      ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.id'                                       ;;
        created                                 ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.created'                                  ;;
        last_updated                            ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.last_updated'                             ;;
        scenario | scenario_type                ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.scenario_type'                            ;;
        reservation | reservation_id            ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.reservation_id'                           ;;
        instance | instances                    ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.instances'                                ;;
        notes                                   ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.notes'                                    ;;
        origin_endpoint_id                      ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.origin_endpoint_id'                       ;;
        origin_minion_pool_id                   ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.origin_minion_pool_id'                    ;;
        destination_endpoint_id                 ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.destination_endpoint_id'                  ;;
        destination_minion_pool_id              ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.destination_minion_pool_id'               ;;
        instance_osmorphing_minion_pool_mappings) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.instance_osmorphing_minion_pool_mappings' ;;
        destination_environment                 ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.destination_environment' | ${cmd_jq} -s   ;;
        source_environment                      ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.source_environment' | ${cmd_jq} -s        ;;
        network_map                             ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.network_map'                              ;;
        disk_storage_mappings                   ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.disk_storage_mappings'                    ;;
        storage_backend_mappings                ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.storage_backend_mappings'                 ;;
        default_storage_backend                 ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.default_storage_backend'                  ;;
        scripts_linux | user_scripts_linux      ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.user_scripts' | ${cmd_jq} -r 'if( .global.linux ) then .global.linux else null end'     ;;
        scripts_windows | user_scripts_windows  ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.user_scripts' | ${cmd_jq} -r 'if( .global.windows ) then .global.windows else null end' ;;
        clone_disks                             ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.clone_disks'                              ;;
        skip_os_morphing                        ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.skip_os_morphing'                         ;;
        executions                              ) ${cmd_echo} "${transfer}" | ${cmd_jq} -r '.executions'                               ;;

      esac
    done
  else
    ${cmd_cat} "${_tmp_file}" | ${cmd_jq} -sc

  fi

  # cleanup
  shell.log "${FUNCNAME}(${_profile}) - [CLEANUP] Deleting temp file ${_tmp_file}"
  [[ -f ${_tmp_file} ]] && ${cmd_rm} -f ${_tmp_file}

  # exit
  return ${_exit_code}
}