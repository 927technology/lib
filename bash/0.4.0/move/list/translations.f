move.list.translations() {
  # local variables
  local _json=
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
      [[ -f ${_path}/${_profile}/transfers/${_name} ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/translations/${_name}.json 2>/dev/null | ${cmd_jq} -c )

  elif  [[ ! -z ${_filter} ]] && \
        [[ -d ${_path}/${_profile}/transfers ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/translations/*.json 2>/dev/null | ${cmd_jq} -c '. | select(( .name? | ascii_downcase ) | match("'"${_filter}"'"))' )

  else
    _json=$( ${cmd_cat} ${_path}/${_profile}/translations/*.json 2>/dev/null | ${cmd_jq} -c )

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      exists                      ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .name ) then '${true}' else '${false}' end'                              ;;
      name                        ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.name'                                                                       ;;
      olvm_cluster                ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.olvm.cluster'                                                               ;;
      olvm_data_center            ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.olvm.data_center'                                                           ;;
      olvm_storage_domain         ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.olvm.storage_domain.host'                                                   ;;
      olvm_storage_domain_minion  ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.olvm.storage_domain.minion'                                                 ;;
      olvm_vlan                   ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.olvm.vlan'                                                                  ;;
      coriolis_deployment_date    ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.date.deployment'                                                   ;;
      coriolis_deployment_epoch   ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.date.deployment | to_epoch'                                                   ;;
      coriolis_deployment_enable  ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .coriolis.date.deployment != null ) then '${true}' else '${false}' end'  ;;
      coriolis_transfer_date      ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.date.transfer'                                                     ;;
      coriolis_transfer_epoch     ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.date.transfer | to_epoch'                                                     ;;
      coriolis_transfer_enable    ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .coriolis.date.transfer != null ) then '${true}' else '${false}' end'    ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}