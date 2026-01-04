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

  # clear cached data
  [[ -d ${_path}/${_profile}/transfers/schedules ]] && ${cmd_rm} -rf ${_path}/${_profile}/transfers/schedules
  ${cmd_mkdir} -p ${_path}/${_profile}/transfers/schedules

  for endpoint in $( move.coriolis.list.active --output name ); do
    # set endpoint
    move.coriolis.set.endpoint --name ${endpoint}

    # interate transfers
    for transfer in $( move.coriolis.list.transfers --output name ); do
      # zero out loop data
      _json=

      # iterate schedules
      for schedule in $( ${cmd_coriolis} transfer schedule list -f json ${transfer} 2>/dev/null | ${cmd_jq} -c '.[]' ); do
        # zero out loop data
        _id=
        
        _id=$( ${cmd_echo} ${schedule} | ${cmd_jq} -r '.ID' )

        ${cmd_echo} "${schedule}" > ${_path}/${_profile}/transfers/schedules/${_id}.json
        shell.log "${FUNCNAME}(${_profile}) - [SUCCESS]  End Point: ${endpoint}, ID: ${_id}"

      done
    done
  done

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"


  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}