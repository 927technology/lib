coriolis.get.transfers.execution.status() {
  # local variables
  local _tmp_file=
  local _path=~move/move

  # argument variables
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
  [[ -z ${_profile} ]] && { shell.log "${FUNCNAME}(${_profile}) - [PROFILE] Profile is not set.   Set profile move.set.profile --name <profile name>"; return ${exit_crit}; }

  # set endpoint
  move.coriolis.set.endpoint --profile ${_profile}

  if  [[ ! -z  ${_name} ]]; then
    # query coriolis for execution status
    _json=$(                              \
      ${cmd_coriolis}                     \
        transfer                          \
        execution                         \
        list                              \
        -f json                           \
        $(                                \
          move.list.transfers.created     \
            --latest                      \
            --name ${_name}               \
            --output id                   \
            --profile ${_profile}         \
        ) | ${cmd_jq} -c '.[-1]'          \
    )

    if [[ ${_json} != "{}" ]]; then
      case $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.Status' ) in
        COMPLETED ) _exit_code=${exit_ok}   ;;
        ERROR     ) _exit_code=${exit_crit} ;;
        *         ) _exit_code=${exit_warn} ;;
      esac
    else
      _exit_code=${exit_warn}

    fi

  else
    _exit_code=${exit_warn}

  fi

  if [[ ! -z ${_output} ]]; then
    for execute in $( ${cmd_echo} ${_json} | ${cmd_jq} -c ); do
      case ${_output} in
        created                           ) ${cmd_echo} "${execute}" | ${cmd_jq} -r '.created'                  ;;
        id                                ) ${cmd_echo} "${execute}" | ${cmd_jq} -r '.ID'                       ;;
        status                            ) ${cmd_echo} "${execute}" | ${cmd_jq} -r '.Status | ascii_downcase'  ;;
        transfer_id                       ) ${cmd_echo} "${execute}" | ${cmd_jq} -r '.Transfer_ID'              ;;

      esac
    done
  else
    ${cmd_echo} "${_json}" | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}