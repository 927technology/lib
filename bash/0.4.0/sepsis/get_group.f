sepsis.get_group() {
  # description


  # dependancies
  # date/week.f
  # json/set.f

  # argument variables
  local _json=
  local _json_config=
  local _json_hosts=

  # local variables
  local _day_of_week=$( date.day_of_week )
  local _hostgroup=
  local _week_mod=$( ${cmd_echo} $(( $( date.week ) % 4 )) )

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  
  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j  | --json )
        shift
        _json_config="${1}"
      ;;
    esac
    shift
  done

  # main
  if [[ $( ${cmd_echo} ${_json_config} | is_json ) == ${true} ]]; then
    _hostgroup=$( ${cmd_echo} "${_json_config}"   | ${cmd_jq} -c '.groups[] | select(( try(.enable) == true ) and try(.day_of_week) == '${_day_of_week}' ).hostgroup' )
    _day_of_week_string=$( ${cmd_echo} "${_json_config}"   | ${cmd_jq} -c '.groups[] | select(( try(.enable) == true ) and try(.day_of_week) == '${_day_of_week}' ).name' )
    _json_hosts=$( ${cmd_echo} "${_json_config}"  | ${cmd_jq} -c  '[[ .hosts[] | select(( try(.enable) == true ) and try(.hostgroup) == '${_hostgroup}' ).fqdn ] | to_entries[] | select( ( .key % 4 ) == '${_week_mod}' ).value ]' )
    # _json_hosts=$( ${cmd_echo} "${_json_config}"  | ${cmd_jq} -c  '[ .hosts[] | select(( try(.enable) == true ) and try(.hostgroup) == '${_hostgroup}').fqdn ]' )





    _json=$( json.set --json ${_json} --key .day_of_week.number --value ${_day_of_week}                         || (( _error_count++ )) )
    _json=$( json.set --json ${_json} --key .day_of_week.string --value ${_day_of_week_string}                  || (( _error_count++ )) )
    _json=$( json.set --json ${_json} --key .hostgroup          --value ${_hostgroup}                           || (( _error_count++ )) )
    _json=$( json.set --json ${_json} --key .hosts              --value "${_json_hosts}"                        || (( _error_count++ )) )
    _json=$( json.set --json ${_json} --key .week.number        --value $( date.week )                          || (( _error_count++ )) )
    _json=$( json.set --json ${_json} --key .week.mod           --value ${_week_mod}                            || (( _error_count++ )) )
    
    # set runtime in json
    _json=$( json.set --json ${_json} --key .time.completed     --value $( date.epoch )                         || (( _error_count++ )) )
  fi

  _exit_string=${_json}
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}