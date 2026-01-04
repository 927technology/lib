coriolis.get.endpoints.source.options() {
  # edited
  # chris murray
  # 20251120

  # description
  # queries coriolis endpoints set in connect.json for ${_profile}
  # deletes existing cache and writes output to ${_path}/${_profile}/endpoints/source/options as json -c format

  # local variables
  local _count_options=0
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

  # loop scoped variables
  local endpoint=
  local option=

  # parse arguments
  while [[ "${1}" != "" ]]; do
    case "${1}" in
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
  [[ -d ${_path}/${_profile}/endpoints/source/options ]] && ${cmd_rm} -rf ${_path}/${_profile}/endpoints/source/options
  ${cmd_mkdir} -p ${_path}/${_profile}/endpoints/source/options

  for endpoint in $( move.vsphere.list.endpoints --profile ${_profile} --output name ); do
    # zero out loop variables
    _json="{}"

    for option in $( ${cmd_coriolis} endpoint source options list --format json  ${endpoint} 2>/dev/null | ${cmd_jq} -c '.[]' ); do 
      # set option values
      _json=$( json.set --json ${_json} --key .options[${_count_options}].name     --value $( ${cmd_echo} ${option} | ${cmd_jq} -r '."Option Name"' )                     || (( _error_count++ )) )
      _json=$( json.set --json ${_json} --key .options[${_count_options}].values   --value $( ${cmd_echo} ${option} | ${cmd_jq} -r '."Possible Values"' | ${cmd_jq} -c )  || (( _error_count++ )) )
      _json=$( json.set --json ${_json} --key .options[${_count_options}].default  --value $( ${cmd_echo} ${option} | ${cmd_jq} -r '."Configuration Default"' )           || (( _error_count++ )) )
      
      shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${endpoint}, Option:$( ${cmd_echo} ${option} | ${cmd_jq} -r '."Option Name"' ) "

      (( _count_options++ ))
    done
    # output json
    ${cmd_echo} "${_json}" > ${_path}/${_profile}/endpoints/source/options/${endpoint}.json
  
  done

  shell.log "${FUNCNAME}(${_profile}) - [Compete]"

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}