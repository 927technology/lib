move.vsphere.list.active() {
  # local variables
  local _count=0
  local _output=

  # argument variables
  local _profile=
  local _output=
  local _short=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local endpoint=
  local profile=

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
      -s | --short )
        _output=name
      ;;
    esac
    shift
  done

  # main
  # set credentials
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}


  if [[ ! -z ${_profile} ]]; then
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '[ .[] | select(( .name == "'"${_profile}"'" ) and .enable == '${true}' ) ]' )

  else
    (( _error_count++ ))

  fi

  # itterate active profiles
  for profile in $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[].name ' ); do

    # itterate active endpoints
    for endpoint in $( move.vsphere.list.endpoints --profile ${profile} | ${cmd_jq} -c '.[]' ); do
      if [[ ! -z ${_output} ]]; then
        case ${_output} in
          name                  ) ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.endpoint'                                                                ;;
          table                 )
            ${cmd_echo}
            ${cmd_echo} VSphere - Active Endpoints

            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Profile"                             ${MOVE_PROFILE}

            ${cmd_printf} "------------------------------------------------------------------------\n"
            ${cmd_printf} "%-2s %-30s : %-20s\n" "$(( ${_count} + 1 ))" "Endpoint Name" $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.endpoint  | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "Password"                          "**********"
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "User Name"                         $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.user      | if( . == null ) then "unset" else . end' )
            ${cmd_printf} "%-2s %-30s : %-20s\n" "" "VSphere Server"                    $( ${cmd_echo} ${endpoint} | ${cmd_jq} -r '.server    | if( . == null ) then "unset" else . end' )
          ;;

        esac
      else
        ${cmd_echo} ${_json} | ${cmd_jq} -sc

      fi

      (( _count++ ))
    done
  done

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}