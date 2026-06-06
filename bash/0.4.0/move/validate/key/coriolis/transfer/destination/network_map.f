move.validate.key.coriolis_transfer_destination_network_map() {
  # local variables
  local _count=0
  local _key=.coriolis.transfer.destination.network_map
  local _type=network_map

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json="{}"
  local host=

  # argument variables
  local _name=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -p | --profile )
        shift
        _profile="${1}"
      ;;
     esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  [[ -z ${_profile} ]] && return ${exit_crit}

  _json=$( move.list.transfers --name ${_name} --profile ${_profile} | ${cmd_jq} -c '.[]' )

  if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} -r "${_key}" ) == null ]]; then
    shell.log "${FUNCNAME}(${_profile}) - [VALID]      VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name' ), KEY: ${_key}, VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r ${_key} )"
    
  else
    # value is no "blank"
    shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [INVALID]  VM: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.name' ), KEY: "${_key}", VALUE: $( ${cmd_echo} ${_json} | ${cmd_jq} -r ${_key} )"
    shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [FIX]      move.set.transfers --host ${_name} --key "${_key}" --profile ${_profile} --value null"

    (( _error_count++ ))

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}