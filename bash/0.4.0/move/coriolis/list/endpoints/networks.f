move.coriolis.list.endpoints.networks() {
  #_description: Displays networks cached from the Coriolis Server
  #_filter: true
  #_name: true
  #_arguments: --filter,--name,--output
  #_output: id,endpoint,endpoint_id,name,olvm_datacenter,vlan

  # local variables
  local _json=
  local _path=~move/coriolis

  # argument variables
  local _id=
  local _filter=
  local _name=
  local _output=
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter=$( ${cmd_echo} ${1} | lcase )
      ;;
      -n | --name )
        shift
        _name=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -o | --output )
        shift
        _output="${1}"
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  if  [[ ! -z  ${_name} ]]            && \
      [[ -d ${_path}/${_profile}/endpoints/networks ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/endpoints/networks/*.json 2>/dev/null | ${cmd_jq} -c '. | select( ( .name.parts[0] | ascii_downcase ) == "'"${_name}"'" )' && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  elif  [[ -d ${_path}/${_profile}/endpoints/networks ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/endpoints/networks/*.json 2>/dev/null | ${cmd_jq} -c && _exit_code=${exit_ok} || _exit_code=${exit_crit} )
  
  else
    _exit_code=${exit_crit}

  fi

  # filter output
  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      id              ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.id'                                       ;;
      endpoint_id     ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.endpoint.id'                              ;;
      endpoint        ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.endpoint.name' | ${cmd_uniq} | ${cmd_sort} ;;
      name            ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name.parts[0] | if( . != "ovirtmgmt" ) then . else empty end' ;;
      olvm_datacenter ) ${cmd_echo} "${_json}" | ${cmd_jq}    '.olvm.datacenter | if( . != "default" ) then . else empty end' | ${cmd_jq} -sc '. | unique | sort' ;;
      # olvm_datacenter ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.olvm.datacenter' | ${cmd_grep} -v default | ${cmd_uniq} | ${cmd_sort} ;;
      vlan            ) ${cmd_echo} "${_json}" | ${cmd_jq}    '.move.network.vlan | if( . != null ) then . else empty end' | ${cmd_jq} -sc '. | unique | sort' ;;
    esac
  
  else
    ${cmd_echo} "${_json}" | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}