coriolis.get.transfers() {
  # edited
  # chris murray
  # 20251120

  # description
  # queries coriolis endpoints set in connect.json for ${_profile}
  # deletes existing cache and writes output to ${_path}/${_profile}/transfers as json -c format

  # local variables
  local _id=
  local _json=
  local _last_execution_status=
  local _name=
  local _path=~move/coriolis
  local _subdirectory=
  
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
  [[ -d ${_path}/${_profile}/transfers ]] && ${cmd_rm} -rf ${_path}/${_profile}/transfers/*.json
  ${cmd_mkdir} -p ${_path}/${_profile}/transfers

  # set endpoint
  move.coriolis.set.endpoint --profile ${_profile}

  # get transfer information
  _json=$( ${cmd_coriolis} transfer list --format json 2>/dev/null | ${cmd_jq} )
  
  # parse transfer information
  for transfer in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[]' ); do
    # zero out loop variables
    _id=
    _name=
    _last_execution_status=

    # set loop variables
    _id=$( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.ID' )
    _name=$( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.Instances' | ${cmd_sed} 's/\//-/g' )

    shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] ID: ${_id}, VM: VM: $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.Instances | split("/") | .[-1]' )"

    # create new cache
    ${cmd_echo} ${transfer} > ${_path}/${_profile}/transfers/${_id}.json
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 

  done

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}