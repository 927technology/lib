coriolis.get.transfers.schedules() {
  # edited
  # chris murray
  # 20251120

  # description
  # queries coriolis endpoints set in connect.json for ${_profile}
  # deletes existing cache and writes output to ${_path}/${_profile}/transfers/schedules as json -c format

  # local variables
  local _id=
  local _json=
  local _path=~move/coriolis

  # argument variables
  local _profile=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -p  | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
    esac
    shift
  done

  # main
  # set credentials
  [[ -z ${_profile} ]] && { shell.log "${FUNCNAME}(${_profile}) - [PROFILE] Profile is not set.   Set profile move.set.profile --name <profile name>"; return ${exit_crit}; }

  # clear cached data
  [[ -d ${_path}/${_profile}/transfers/schedules ]] && ${cmd_rm} -rf ${_path}/${_profile}/transfers/schedules
  ${cmd_mkdir} -p ${_path}/${_profile}/transfers/schedules

  # set endpoint
  move.coriolis.set.endpoint --profile ${_profile}

  # interate transfers
  for transfer in $( move.coriolis.list.transfers --output name --profile ${_profile} ); do
    # zero out loop data
    _json=

    # iterate schedules
    for schedule in $( ${cmd_coriolis} transfer schedule list -f json ${transfer} 2>/dev/null | ${cmd_jq} -c '.[]' ); do
      # zero out loop data
      _id=
      
      _id=$( ${cmd_echo} ${schedule} | ${cmd_jq} -r '.ID' )
      ${cmd_echo} "${schedule}" > ${_path}/${_profile}/transfers/schedules/${_id}.json
      shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] ID: ${_id}, VM: $( ${cmd_echo} ${deployment} | ${cmd_jq} -r '.Instances | split("/") | .[-1]' )"

    done
  done

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"


  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}