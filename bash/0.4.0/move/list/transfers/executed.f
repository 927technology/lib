move.list.transfers.executed() {
  # local variables
  local _json="{}"
  local _path=~move/move

  # argument variables
  local _filter=
  local _name=
  local _output=
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -i | --id )
        # held over from legacy (depricated)
        output=id
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

  if  [[ ! -z  ${_name} ]]    && \
      [[ -d ${_path}/${_profile}/transfers/execute/${_name} ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/transfers/execute/${_name}/*.json | ${cmd_jq} -s | ${cmd_jq} -c '. | sort_by( .created ) | .[-1]' 2>/dev/null && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  else
    _exit_code=${exit_crit}

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      id                                      ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.id'                                       ;;
      created                                 ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.created'                                  ;;
      last_updated                            ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.last_updated'                             ;;
      scenario | scenario_type                ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.scenario_type'                            ;;
      reservation | reservation_id            ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.reservation_id'                           ;;
      instance | instances                    ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.instances'                                ;;
      notes                                   ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.notes'                                    ;;
      origin_endpoint_id                      ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.origin_endpoint_id'                       ;;
      origin_minion_pool_id                   ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.origin_minion_pool_id'                    ;;
      destination_endpoint_id                 ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.destination_endpoint_id'                  ;;
      destination_minion_pool_id              ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.destination_minion_pool_id'               ;;
      instance_osmorphing_minion_pool_mappings) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.instance_osmorphing_minion_pool_mappings' ;;
      destination_environment                 ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.destination_environment' | ${cmd_jq} -s   ;;
      source_environment                      ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.source_environment' | ${cmd_jq} -s        ;;
      network_map                             ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.network_map'                              ;;
      disk_storage_mappings                   ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.disk_storage_mappings'                    ;;
      storage_backend_mappings                ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.storage_backend_mappings'                 ;;
      default_storage_backend                 ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.default_storage_backend'                  ;;
      scripts_linux | user_scripts_linux      ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.user_scripts' | ${cmd_jq} -r 'if( .global.linux ) then .global.linux else null end'     ;;
      scripts_windows | user_scripts_windows  ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.user_scripts' | ${cmd_jq} -r 'if( .global.windows ) then .global.windows else null end' ;;
      clone_disks                             ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.clone_disks'                              ;;
      skip_os_morphing                        ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.skip_os_morphing'                         ;;
      executions                              ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.executions'                               ;;

    esac
  
  else
    ${cmd_echo} "${_json}" | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}