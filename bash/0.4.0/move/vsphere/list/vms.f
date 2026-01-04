move.vsphere.list.vms() {
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
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}

  if  [[ ! -z  ${_name} ]]            && \
      [[ -d ${_path}/${_profile}/vms ]]; then
      echo 10
    _json=$( ${cmd_cat} ${_path}/${_profile}/vms/*.json 2>/dev/null | ${cmd_jq} '. | select( .Name == "'"${_name}"'" )' || (( _error_count++ )) )

  elif  [[ ! -z ${_filter} ]] && \
        [[ -d ${_path}/${_profile}/vms ]]; then
        echo 20
    _json=$( ${cmd_cat} ${_path}/${_profile}/vms/*.json 2>/dev/null | ${cmd_jq} '. | select(( .Name? | ascii_downcase ) | match("'"${_filter}"'"))' || (( _error_count++ )) )

  elif  [[ -d ${_path}/${_profile}/vms ]]; then
  echo 30
    _json=$( ${cmd_cat} ${_path}/${_profile}/vms/*.json 2>/dev/null 2>/dev/null | ${cmd_jq} -c || (( _error_count++ )) )

  else
  echo 40
    _exit_code=${exit_crit}

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      datacenter      ) ${cmd_echo} ${_json} | ${cmd_jq} -c '{"datacenter": .DataCenter, "name": .Name }' ;;
      cluster         ) ${cmd_echo} ${_json} | ${cmd_jq} -r '{"cluster": .Cluster, "name": .Name }'       ;;
      id              ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.ID'                                         ;;
      power           ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.PowerState'                                 ;;
      name            ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.Name' | ${cmd_sort}                         ;;
      networkadapters ) ${cmd_echo} ${_json} | ${cmd_jq}    '.NetworkAdapters | length'                   ;;
      harddisks       ) ${cmd_echo} ${_json} | ${cmd_jq}    '.HardDisks | length'                         ;;
      os              ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.GuestOS'                                    ;;
      os_id           ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.GuestID'                                    ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}