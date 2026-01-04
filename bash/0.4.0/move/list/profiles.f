move.list.profiles() {
  # local variables
  local _json="{}"
  local _path=~move/move

  # argument variables
  local _output=

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
  if [[ ! -z ${_profile} ]]; then
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '.[] | select(( .name == "'"${_profile}"'" ) and .enable == '${true}' )' )

  else
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '.[] | select( .enable == '${true}' )' )

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      name                 ) ${cmd_echo} ${_json} | ${cmd_jq} -r '.name'                                                                ;;

    esac
  
  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi

  # exit
  return ${_exit_code}
}