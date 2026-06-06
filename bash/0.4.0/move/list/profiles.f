move.list.profiles() {
  # local variables
  local _json="{}"
  local _path=~move/move

  # argument variables
  local _output=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
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
  # [[ -z ${_profile} ]] && return ${exit_crit}

  if [[ ! -z ${_profile} ]]; then
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '.[] | select(( .name == "'"${_profile}"'" ) and .enable == '${true}' )' )

  else
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '.[] | select( .enable == '${true}' )' )

  fi


  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      coriolis             ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis | select( .[0].enable == '${true}' )'           ;;
      coriolis_server      ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.coriolis | select( .[0].enable == '${true}' )[0].server' ;;
      enable               ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.enable'                                                  ;;
      name                 ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.name'                                                    ;;
      rapid_key            ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.auth.rapid.key'                                          ;;
      rapid_secret         ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.auth.rapid.secret'                                       ;;
      vault                ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.auth.vault.name'                                         ;;
      vsphere              ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere | select( .[0].enable == '${true}' )'            ;;
      vsphere_server       ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere | select( .[0].enable == '${true}' )[0].server'  ;;

    esac
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}