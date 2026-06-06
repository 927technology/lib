coriolis.delete.transfers() {
  # local variables
  local _tmp_file=
  local _transfer_id=
  local _path=~move/move

  # argument variables
  local _name=
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -n | --name )
        shift
        _name=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  # set endpoint
  move.coriolis.set.endpoint --profile ${_profile}

  if  [[ ! -z  ${_name} ]]; then
    # query coriolis for deployments, match transfer id, and get last deployment cronologically
    _json=$(                          \
      ${cmd_coriolis}                 \
        transfer                      \
        delete                        \
        $(                            \
          move.list.transfers.created \
          --latest                    \
          --name ${_name}             \
          --output id                 \
          --profile ${_profile}       \
          2>/dev/null                 \
        )                             \
        2>/dev/null 
    ) 
    case ${?} in
      0 ) _exit_code=${exit_ok}   ;;
      1 ) _exit_code=${exit_warn} ;;
      * ) _exit_code=${exit_crit} ;;
    esac
  else
    _exit_code=${exit_crit}

  fi

  # exit
  return ${_exit_code}
}