move.coriolis.list.endpoints.storage() {
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
      -p  | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  if    [[ ! -z ${_name} ]] &&                                                                      \
        [[ -d ${_path}/${_profile}/endpoints/storage/ ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/endpoints/storage/*.json | ${cmd_jq} '. | select( ( .olvm.domain | ascii_downcase ) == "'${_name}'" )' )

  elif  [[ -d ${_path}/${_profile}/endpoints/storage/ ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/endpoints/storage/*.json )

  else
    _exit_code=${exit_crit}

  fi

  # filter output
  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      domain          ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.olvm.domain'                        ;;
      id              ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.id'                                 ;;
      name            ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name.full'                          ;;
    esac
  
  else
    ${cmd_echo} "${_json}" | ${cmd_jq} -sc

  fi   

  # exit
  return ${_exit_code}
}