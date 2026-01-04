coriolis.get.deployments() {
  # edited
  # chris murray
  # 20251120

  # description
  # queries coriolis endpoints set in connect.json for ${_profile}
  # deletes existing cache and writes output to ${_path}/${_profile}/deployments as json -c format

  # local variables
  local _id=
  local _json=
  local _name=
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
  [[ -d ${_path}/${_profile}/deployments ]] && ${cmd_rm} -rf ${_path}/${_profile}/deployments
  ${cmd_mkdir} -p ${_path}/${_profile}/deployments

  for endpoint in $( move.coriolis.list.active --output name ); do
    # zero out loop data
    _json=

    # set endpoint
    move.coriolis.set.endpoint --name ${endpoint}

    _json=$( ${cmd_coriolis} deployment list -f json 2>/dev/null | ${cmd_jq} )
    
    for deployment in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[]' ); do
      # zero out loop variables
      _id=
      _name=

      _id=$( ${cmd_echo} ${deployment} | ${cmd_jq} -r '.ID' )
      _name=$( ${cmd_echo} ${deployment} | ${cmd_jq} -r '.Instances' | ${cmd_sed} 's/\//-/g' )

      ${cmd_echo} ${deployment} > ${_path}/${_profile}/deployments/${_id}.json
      [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 

        shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${endpoint}, ID: ${_id}"

    done
  done
  
  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}