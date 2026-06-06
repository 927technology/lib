move.vsphere.list.networks() {
  # local variables
  local _json=
  local _path=~move/vsphere

  # argument variables
  local _filter=
  local _name=
  local _id=
  local _output=
  local _profile=
  # local _short=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -i | --id )
        _id=${true}
      ;;
      -o | --output )
        shift
        _output=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -s | --short )
        _output=name
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  if  [[ ! -z  ${_name} ]]            && \
      [[ -d ${_path}/${_profile}/networks ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/networks/*.json 2>/dev/null | ${cmd_jq} '. | select( .name == "'"${_name}"'" )' || (( _error_count++ )) )

  elif  [[ ! -z ${_filter} ]] && \
        [[ -d ${_path}/${_profile}/networks ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/networks/*.json 2>/dev/null | ${cmd_jq} '. | select(( .name? | ascii_downcase ) | match("'"${_filter}"'"))' || (( _error_count++ )) )

  elif  [[ -d ${_path}/${_profile}/networks ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/networks/*.json 2>/dev/null | ${cmd_jq} -c || (( _error_count++ )) )

  else
    _exit_code=${exit_crit}

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      name            ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.name'                   ;;
      vm_host         ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vm_host'                ;;
      vlan_id         ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vlan_id'                ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}