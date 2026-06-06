move.list.vms() {
  # local variables
  local _json=
  local _path=~move/move

  # argument variables
  local _filter=
  local _name=
  local _id=
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
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && { shell.log "${FUNCNAME}(${_profile}) - [PROFILE] Profile is not set.   Set profile with the --profile <profile name> flag"; return ${exit_crit}; }

  if  [[ ! -z  ${_name} ]]    && \
      [[ -f ${_path}/${_profile}/transfers/vms/${_name} ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/transfers/vms/${_name} 2>/dev/null && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  elif  [[ ! -z ${_filter} ]] && \
        [[ -d ${_path}/${_profile}/transfers/vms ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/transfers/vms/*.json 2>/dev/null | ${cmd_jq} '. | select(( .name? | ascii_downcase ) | match("'"${_filter}"'"))' )

  elif  [[ -d ${_path}/${_profile}/transfers/vms ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/transfers/vms/*.json 2>/dev/null | ${cmd_jq} -c && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  else
    _exit_code=${exit_crit}

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      id              ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere.host.id'                                         ;;
      mac             ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.networkadapters[0].macaddress'        ;;
      name            ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.name'                                 ;;
      # networkadapters ) ${cmd_echo} ${_json} | ${cmd_jq}    '.networkadapters | length'           ;;
      networkadapters ) ${cmd_echo} ${_json} | ${cmd_jq}    '.networkadapters'                      ;;
      harddisks       ) ${cmd_echo} ${_json} | ${cmd_jq}    '.harddisks | length'                   ;;
      os              ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere.host.guestos'                 ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}