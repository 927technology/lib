move.list.transfers() {
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
      -s | --short )
        # held over from legacy (depricated)
        _output=name
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  
  if  [[ ! -z  ${_name} ]]    && \
      [[ -f ${_path}/${_profile}/transfers/${_name} ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/transfers/${_name} 2>/dev/null && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  elif  [[ ! -z ${_filter} ]] && \
        [[ -d ${_path}/${_profile}/transfers ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/transfers/*.json 2>/dev/null | ${cmd_jq} '. | select(( .name? | ascii_downcase ) | match("'"${_filter}"'"))' )

  else
    _exit_code=${exit_crit}

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      id                   ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere.host.id'                                                     ;;
      name                 ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.name'                                                                ;;
      networkadapters      ) ${cmd_echo} ${_json} | ${cmd_jq}    '.networkadapters'                                                     ;;
      networkadapters_count) ${cmd_echo} ${_json} | ${cmd_jq}    '.networkadapters | length'                                            ;;
      harddisks            ) ${cmd_echo} ${_json} | ${cmd_jq}    '.harddisks'                                                           ;;
      harddisks_count      ) ${cmd_echo} ${_json} | ${cmd_jq}    '.harddisks | length'                                                  ;;
      os                   ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere.host.guestos'                                                ;;
      config               ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis.transfer'                                                   ;;
      family               ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.move.coriolis.transfer.destination.os.family'                        ;;
      olvm_os              ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.move.coriolis.transfer.destination.os.olvm'                          ;;
      enable               ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.move.coriolis.transfer.enable | if( . == true ) then '${true}' else '${false}' end' ;;
      data                 ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'try(.data) | if( . == null ) then [] else . end'                      ;;
      transfer             ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'try(.data.transfer) | if( . == null ) then [] else . end'             ;;
      transfer_schedule    ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'try(.data.transfer_schedule) | if( . == null ) then [] else . end'    ;;
      deployment           ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'try(.data.deployment) | if( . == null ) then [] else . end'           ;;
      deployment_schedule  ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'try(.data.deployment_schedule) | if( . == null ) then [] else . end'  ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}