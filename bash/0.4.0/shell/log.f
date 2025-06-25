shell.log () {
  # description
  # accepts arguments and prints to screen and/or syslog
  ## -m | --message is the string to print to screen/syslog
  ## -s | --screen sets if the message will be printed to the screen
  ## -t | --tag sets the syslog tag to be used. syslog will not be used if tag is not specified
  ## -j | --json message is in json format.  json overwrites message if both are present

  # dependancies
  # date/pretty.f
  # json/set.f
  # standard/is_json.f
  # variables/cmd_<platform>.v
  # variables/exits.v

  IFS=$'\n'  # because IFS sucks

  # argument variables
  local _message=
  local _json_message=
  local _screen_output=${false}
  local _syslog_tag=

  # control variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=

  # local variables
  local _is_json=${false}
  local _json="{}"
  local _remote_server=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j  | --json )
        shift
        # validate json
        if [[ $( ${cmd_echo} "${1}" | is_json ) == ${true} ]]; then
          _is_json=${true}
          _json_message="${1}"
        else
          _json_message="{}"
        fi
      ;;
      -m  | --message )
        shift
        _message="${1}"
      ;;
      -s  | --screen )
        _screen_output=${true}
      ;;
      -t  | --tag )
        shift
        _syslog_tag="${1}"
      ;;
    esac
    shift
  done

  # main
  # message is not empty
  if  [[ ! -z ${_message}       ]]  ||
      [[ ! -z ${_json_message}  ]]; then

    # parse message from json if present
    [[ ${_is_json} == ${true} ]] && _message=$( ${cmd_echo} ${_json_message} | ${cmd_jq} -r 'try(.message) | if( . != null ) then . else "no message provided" end' ) || (( _error_count++ ))

    # add runid to json
    [[ ! -z ${RUN_ID} ]] && [[ ${_is_json} == ${true} ]] && _json_message=$( json.set --json ${_json_message} --key .run_id --value ${RUN_ID} || (( _err_count++ )) ) 

    # add runid to message
    [[ ! -z ${RUN_ID} ]] && _message=$( ${cmd_echo} "${RUN_ID}: ${_message}" || (( _error_count++ )) )

    # output to screen
    [[ ${_screen_output} == ${true} ]] && _exit_string=$( ${cmd_echo} "$( date.pretty ) - ${_message}" 2>/dev/null || (( _error_count++ )) )

    # output to syslog
    if [[ ! -z ${_syslog_tag} ]]; then
      # set syslog server to local host if none is provided
      [[ -z ${_remote_server} ]] && _remote_server=localhost

      # output message
      ${cmd_logger} --tag ${_syslog_tag} --server ${_remote_server} "${_message}" || (( _error_count++ ))
    fi
  fi

  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}