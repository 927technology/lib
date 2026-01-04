move.list.vms() {
  # local variables
  local _json=
  local _path=~move/move

  # argument variables
  local _filter=
  local _name=
  local _id=
  local _output=

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
      -s | --short )
        _output=name
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z  ${_name} ]]    && \
      [[ -f ${_path}/${MOVE_PROFILE}/transfers/vms/${_name} ]]; then
    _json=$( ${cmd_cat} ${_path}/${MOVE_PROFILE}/transfers/vms/${_name} 2>/dev/null && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  elif  [[ ! -z ${_filter} ]] && \
        [[ -d ${_path}/${MOVE_PROFILE}/transfers/vms ]]; then
    _json=$( ${cmd_cat} ${_path}/${MOVE_PROFILE}/transfers/vms/*.json 2>/dev/null | ${cmd_jq} '. | select(( .name? | ascii_downcase ) | match("'"${_filter}"'"))' )

  elif  [[ -d ${_path}/${MOVE_PROFILE}/transfers/vms ]]; then
    _json=$( ${cmd_cat} ${_path}/${MOVE_PROFILE}/transfers/vms/*.json 2>/dev/null | ${cmd_jq} -c && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  else
    _exit_code=${exit_crit}

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      id              ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere.host.id'                                         ;;
      name            ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.name'                                       ;;
      networkadapters ) ${cmd_echo} ${_json} | ${cmd_jq}    '.networkadapters | length'                   ;;
      harddisks       ) ${cmd_echo} ${_json} | ${cmd_jq}    '.harddisks | length'                         ;;
      os              ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere.host.guestos'                                    ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}