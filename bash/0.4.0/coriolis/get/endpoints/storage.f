coriolis.get.endpoints.storage() {
  # edited
  # chris murray
  # 20251120

  # description
  # queries coriolis endpoints set in connect.json for ${_profile}
  # deletes existing cache and writes output to ${_path}/${_profile}/endpoints/storage as json -c format

  # local variables
  local _count_name=0
  local _id=
  local _json="{}"
  local _json_endpoint="{}"
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
  [[ -d ${_path}/${_profile}/endpoints/storage ]] && ${cmd_rm} -rf ${_path}/${_profile}/endpoints/storage
  ${cmd_mkdir} -p ${_path}/${_profile}/endpoints/storage

  
  # set endpoint
  move.coriolis.set.endpoint --profile ${_profile}

  # get endpoint data
  # _json_endpoint=$( move.coriolis.list.endpoints --name $( move.coriolis.list.active --output name --profile ${_profile} ) | ${cmd_jq} -c '.[]' )

  for storage in $( ${cmd_coriolis} endpoint storage list -f json $( move.coriolis.list.active --output name --profile ${_profile} ) 2>/dev/null | ${cmd_jq} -c '.[]' ); do 
    # zero out loop variables
    _count_name=0
    _json="{}"
    _id=
    _name=

    # set endpoint values
    _json=$( json.set --json "${_json}" --key .endpoint.id --value ${_id} )
    _json=$( json.set --json "${_json}" --key .endpoint.name --value $( move.coriolis.list.active --output name --profile ${_profile} ) )
    _json=$( json.set --json "${_json}" --key .olvm.domain --value $( ${cmd_echo} ${storage} | ${cmd_jq} -r '.Name' ) )

    # set storage values
    _json=$( json.set --json "${_json}" --key .id --value $( ${cmd_echo} ${storage} | ${cmd_jq} -r '.ID' ) )
    _json=$( json.set --json "${_json}" --key .name.full --value $( ${cmd_echo} ${storage} | ${cmd_jq} -r '.Name' ) )
    _json=$( json.set --json "${_json}" --key .additional_properties --value $( ${cmd_echo} ${storage} | ${cmd_jq} -c '."Additional Properties"' ) )

    # parse parts of name string
    while [[ ${_count_name} < $( ${cmd_echo} ${network} | ${cmd_jq} '.Name | split("/") | length' ) ]]; do
      _json=$( json.set --json "${_json}" --key .name.parts[${_count_name}] --value $( ${cmd_echo} ${network} | ${cmd_jq} -r '.Name | split("/")['${_count_name}']' ) )
      (( _count_name++ ))
    
    done
  
    # output json
    ${cmd_echo} "${_json}" > ${_path}/${_profile}/endpoints/storage/$( ${cmd_echo} ${storage} | ${cmd_jq} -r '.ID' ).json
    ${cmd_ln} -fs $( ${cmd_echo} ${storage} | ${cmd_jq} -r '.ID' ).json ${_path}/${_profile}/endpoints/storage/$( ${cmd_echo} ${storage} | ${cmd_jq} -r '.Name' )
    
    shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( move.coriolis.list.active --output name --profile ${_profile} ), Storage Domain:$( ${cmd_echo} ${storage} | ${cmd_jq} -r '.Name' )"

  done

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"

  # exit
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
  return ${_exit_code}
}