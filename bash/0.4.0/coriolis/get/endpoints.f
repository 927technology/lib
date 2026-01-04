coriolis.get.endpoints() {
  # edited
  # chris murray
  # 20251120

  # description
  # queries coriolis endpoints set in connect.json for ${_profile}
  # deletes existing cache and writes output to ${_path}/${_profile}/endpoints as json -c format

  # local variables
  local _id=
  local _json=
  local _name=
  local _path=~move/coriolis

  # argument variables
  # none

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
  [[ -d ${_path}/${_profile}/endpoints ]] && ${cmd_rm} -rf ${_path}/${_profile}/endpoints
  ${cmd_mkdir} -p ${_path}/${_profile}/endpoints

  for endpoint in $( move.coriolis.list.active --output name || (( _error_count++ )) ); do
    # zero out loop data
    _json=

    # set endpoint
    move.coriolis.set.endpoint --name ${endpoint} || (( _error_count++ ))

    # get endpoint data
    _json=$( ${cmd_coriolis} endpoint list -f json 2>/dev/null | ${cmd_jq} -c )
    for coriolis_endpoint in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[]' ); do
      # zero out loop variables
      _id=
      _name=

      _id=$( ${cmd_echo} ${coriolis_endpoint} | ${cmd_jq} -r '.ID' )
      _name=$( ${cmd_echo} ${coriolis_endpoint} | ${cmd_jq} -r '.Name' )

      shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${_name}"

      # write endpoint    
      ${cmd_echo} "${coriolis_endpoint}" > ${_path}/${_profile}/endpoints/${_id}.json
      [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 

      ${cmd_ln} -fs ${_id}.json ${_path}/${_profile}/endpoints/"${_name}" || (( _error_count++ ))
    done
  
  done

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}