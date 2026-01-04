move.set.profile() {
  # local variables
  # none

  # argument variables
  local _profile=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
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

  if  [[ ! -z ${_profile} ]]; then
    # clear current move profile env
    if [[ ! -z ${MOVE_PROFILE} ]]; then
      unset MOVE_PROFILE
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME} - [SUCCESS] profile unset"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] profile unset"
        (( _error_count++ ))

      fi
    else
      shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] profile not set"

    fi

    # set profile env
    export MOVE_PROFILE=${_profile}
    if [[ ${?} == ${exit_ok} ]]; then
      shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] profile set"

    else
      shell.log "${FUNCNAME}(${_profile}) - FAILURE: Profile not set"
        (( _error_count++ ))

    fi

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_crit}
  return ${_exit_code}
}