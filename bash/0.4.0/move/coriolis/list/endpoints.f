move.coriolis.list.endpoints() {
  #_description: Displays endpoints cached from the Coriolis Server
  #_filter: true
  #_name: true
  #_arguments: --filter,--host,--name,--output,--profile
  #_output: description,id,name,type

  # local variables
  local _json=
  local _path=~move/coriolis

  # argument variables
  local _endpoint=
  local _output=
  local _profile=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
    while [[ ${1} != "" ]]; do 
    case ${1} in
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
  [[ -z ${_profile} ]] && exit ${exit_crit}

  if [[ ! -z ${_profile} ]]; then
    # _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '.[] | select(( .name == "'"${_profile}"'" ) and .enable == '${true}' ).coriolis[] | select( .enable == '${true}' )' )
    _json=$( ${cmd_cat} ${_path}/${_profile}/endpoints/*.json | ${cmd_jq} -c  )

  else
    (( _error_count++ ))

  fi


  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      id                    ) ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.ID'            ;;
      name                  ) ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.Name'          ;;
      type                  ) ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.Type'          ;;
      description           ) ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.Description'   ;;
      # server                ) ${cmd_echo} ${_json}    | ${cmd_jq} -r '.server'        ;;

    esac
  
  else
    ${cmd_echo} "${_json}" | ${cmd_jq} -sc

  fi


  # exit
  return ${_exit_code}
}


