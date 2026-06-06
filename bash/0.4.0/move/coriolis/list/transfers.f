move.coriolis.list.transfers() {
  #_description: Displays transfers cached from the Coriolis Server
  #_filter: false
  #_name: false
  #_arguments: --id,--name,--output,--status
  #_output: created,id,epoch,instances,name,notes,scenerio,status

  # local variables
  local _json=
  local _path=~move/coriolis

  # argument variables
  local _id=
  local _name=
  local _output=
  local _profile=
  local _status=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
    while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -i | --id )
        shift
        _id="${1}"
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
  # set credentials
  [[ -z ${_profile} ]] && { shell.log "${FUNCNAME}(${_profile}) - [PROFILE] Profile is not set.   Set profile move.set.profile --name <profile name>"; return ${exit_crit}; }

  if    [[ ! -z  ${_id} ]]            && \
        [[ -d ${_path}/${_profile}/transfers ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/transfers/*.json 2>/dev/null | ${cmd_jq} '. | select(.ID == "'"${_id}"'" )' && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  elif  [[ ! -z  ${_name} ]]            && \
        [[ -d ${_path}/${_profile}/transfers ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/transfers/*.json 2>/dev/null | ${cmd_jq} '. | select( .Instances | split("/")[-1] == "'"${_name}"'" )' && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  elif  [[ -d ${_path}/${_profile}/transfers ]]; then
    _json=$( ${cmd_cat} ${_path}/${_profile}/transfers/*.json 2>/dev/null | ${cmd_jq} -c && _exit_code=${exit_ok} || _exit_code=${exit_crit} )

  else
    _exit_code=${exit_crit}

  fi

  # filter for status
  if [[ ! -z ${_status} ]]; then
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '. | select(."Last Execution Status" == "'"${_status}"'")' )
  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      created   ) ${cmd_echo} ${_json}  | ${cmd_jq} -r '.Created'                                   ;;
      id        ) ${cmd_echo} ${_json}  | ${cmd_jq} -r '.ID'                                        ;;
      epoch     ) ${cmd_echo} ${_json}  | ${cmd_jq} -r '.Created' | to_epoch                        ;;
      instances ) ${cmd_echo} ${_json}  | ${cmd_jq} -r '.Instances'                                 ;;
      name      ) ${cmd_echo} ${_json}  | ${cmd_jq} -r '.Instances | split("/")[-1]'                ;;
      notes     ) ${cmd_echo} ${_json}  | ${cmd_jq} -r '.Notes'                                     ;;
      scenerio  ) ${cmd_echo} ${_json}  | ${cmd_jq} -r '.Scenerio'                                  ;;
      status    ) ${cmd_echo} ${_json}  | ${cmd_jq} -r '."Last Execution Status" | ascii_downcase'  ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}