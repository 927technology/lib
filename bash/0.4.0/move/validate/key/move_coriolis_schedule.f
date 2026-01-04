move.validate.key.move_coriolis_schedule() {
  # local variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _json=
  local _type=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -t | --type )
        shift
        _type="${1}"
      ;;
      -j | --json )
        shift
        _json=$( ${cmd_echo} "${1}" | ${cmd_jq} -c )
      ;;
     esac
    shift
  done

  # main
  # value is not null
  if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '.move.coriolis."'"${_type}"'".date' ) != null ]]; then
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SET]      VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .move.coriolis.${_type}.date VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.move.coriolis.'${_type}'.date' )"

    # check value is valid epoch
    if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.move.coriolis."'"${_type}"'".date' | from_epoch > /dev/null 2>&1; ${cmd_echo} ${?} ) == ${exit_ok} ]]; then
      shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [VALID]    VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .move.coriolis.${_type}.date VALUE: \"$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.move.coriolis."'"${_type}"'".date' | from_epoch )\""

    # value does not exist in endpoints
    else
      if [[ ${_value} != null ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [INVALID]  VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .move.coriolis.${_type}.date VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.move.coriolis."'"${_type}"'".date' )"
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ) --key .move.coriolis.${_type}.date --value \"<date>\""
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [DATE]     \"$( ${cmd_echo} MM/DD/YYYY HH:mm )\""
        (( _error_count++ ))
      
      fi
    fi

  # value is null
  else
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [UNSET]    VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: .move.coriolis.${_type}.date"
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FIX]      move.set.transfers --host $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ) --key .move.coriolis."${_type}".date --value \"<date>\""
    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [DATE]     \"$( ${cmd_echo} MM/DD/YYYY HH:mm )\""
    (( _error_count++ ))
  
  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}