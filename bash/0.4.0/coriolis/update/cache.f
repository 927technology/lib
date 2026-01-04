coriolis.update.cache() {
  # edited
  # chris murray
  # 20251120

  # description
  # calls functions to update local coriolis cache coriolis.get.${resource}

  # local variables
  local _resources=endpoints,endpoints.networks,endpoints.destination.options,endpoints.source.options,endpoints.storage,deployments,transfers,transfers.schedules

  # argument variables
  local _profile=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ "${1}" != "" ]]; do
    case ${1} in
      -p  | --profile | -n | --name )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  # set credentials
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}

  for resource in $( ${cmd_echo} ${_resources} | ${cmd_sed} 's/,/\n/g' ); do
    shell.log "${FUNCNAME}(${_profile}) - [UPDATING] $( ${cmd_echo} ${resource} | ucase )"

    coriolis.get.${resource} --profile ${_profile} || (( _error_count++ ))

  done

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}