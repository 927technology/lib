coriolis.get.endpoints.networks() {
  # edited
  # chris murray
  # 20251120

  # description
  # queries coriolis endpoints set in connect.json for ${_profile}
  # deletes existing cache and writes output to ${_path}/${_profile}/endpoints/networks as json -c format

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
  [[ -d ${_path}/${_profile}/endpoints/networks ]] && ${cmd_rm} -rf ${_path}/${_profile}/endpoints/networks
  ${cmd_mkdir} -p ${_path}/${_profile}/endpoints/networks

  for endpoint in $( move.coriolis.list.active --output name || (( _error_count++ )) ); do
    # zero out loop variables
    _json_endpoint="{}"

    # set endpoint
    move.coriolis.set.endpoint --name ${endpoint}

    # get endpoint data
    _json_endpoint=$( move.coriolis.list.endpoints --name ${endpoint} | ${cmd_jq} -c '.[]' )

    for network in $( ${cmd_coriolis} endpoint network list -f json  ${endpoint} 2>/dev/null | ${cmd_jq} -c '.[]' ); do 
      # zero out loop variables
      _count_name=0
      _json="{}"
      _id=
      _name=

      # set endpoint values
      _json=$( json.set --json "${_json}" --key .endpoint.id --value $( ${cmd_echo} ${_json_endpoint} | ${cmd_jq} '.ID' ) )
      _json=$( json.set --json "${_json}" --key .endpoint.id --value $( ${cmd_echo} ${_json_endpoint} | ${cmd_jq} '.Name' ) )
      _json=$( json.set --json "${_json}" --key .endpoint.name --value ${endpoint} )
      _json=$( json.set --json "${_json}" --key .olvm.datacenter --value $( ${cmd_echo} ${network} | ${cmd_jq} -r '.Name | split("/")[0] | if( . | split("_")[0] == "ovirtmgmt" ) then "default" else ( . | split("_")[0] ) end' ) )
      _json=$( json.set --json "${_json}" --key .olvm.domain --value ${_name} )

      # set network values
      _json=$( json.set --json "${_json}" --key .id --value $( ${cmd_echo} ${network} | ${cmd_jq} -r '.ID' ) )
      _json=$( json.set --json "${_json}" --key .name.full --value $( ${cmd_echo} ${network} | ${cmd_jq} -r '.Name' ) )
      _json=$( json.set --json "${_json}" --key .move.network.datacenter --value $( ${cmd_echo} ${network} | ${cmd_jq} -r '.Name | split("/")[0] | split("_")[0]' ) )
      _json=$( json.set --json "${_json}" --key .move.network.vlan --value $( ${cmd_echo} ${network} | ${cmd_jq} -r '.Name | split("/")[0] | split("_")[1]' | ${cmd_sed} 's/^VL//g' ) )

      # parse parts of name string
      while [[ ${_count_name} < $( ${cmd_echo} ${network} | ${cmd_jq} '.Name | split("/") | length' ) ]]; do
        _json=$( json.set --json "${_json}" --key .name.parts[${_count_name}] --value $( ${cmd_echo} ${network} | ${cmd_jq} -r '.Name | split("/")['${_count_name}']' ) )
        (( _count_name++ ))
      
      done

      # output json
      ${cmd_echo} "${_json}" > ${_path}/${_profile}/endpoints/networks/$( ${cmd_echo} ${network} | ${cmd_jq} -r '.ID' ).json
      ${cmd_ln} -fs $( ${cmd_echo} ${network} | ${cmd_jq} -r '.ID' ).json ${_path}/${_profile}/endpoints/networks/$( ${cmd_echo} ${network} | ${cmd_jq} -r '.Name | split("/")[0]' )
      
      shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${endpoint}, Data Center:$( ${cmd_echo} ${network} | ${cmd_jq} -r '.Name | split("/")[0] | split("_")[0]' ), VLAN: $( ${cmd_echo} ${network} | ${cmd_jq} -r '.Name | split("/")[0] | split("_")[1]' | ${cmd_sed} 's/^VL//g' )"

    done
  done

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}