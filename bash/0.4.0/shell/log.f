shell.log () {
  # description
  # accepst 1 argument of string and prints timestamp and that string to the screen
  # and the system log
  ## -m | --message is the message to print to screen/syslog
  ## -s | --screen sets if the message will be printed to the screen
  ## -t | --tag sets the syslog tag to be used. syslog will not be used if tag is not specified

  # dependancies
  # 927/cmd_<platform>.v
  # 927/nagios.v
  # date/pretty.f
  # standard/is_json.f

  IFS=$'\n'  # because IFS sucks

  # argument variables
  local _remote_server=
  local _screen_output=${false}
  local _syslog_tag=
  local _message="{}"

  # local variables
  local _date=$( date.pretty )
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _is_json=${false}
  local _json="{}"
  local _syslog_string=
  local _type=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j  | --json )
        _is_json=${true}
        shift
        _message=${1}
      ;;
      -m  | --message )
        shift
        _message=${1}
      ;;
      -r  | --remote )
        shift
        _remote_server=${1}
      ;;
      -s  | --screen )
        _screen_output=${true}
      ;;
      -t  | --tag )
        shift
        _syslog_tag=${1}
      ;;
      -T  | --type )
        shift
        _type=${1}
      ;;
    esac
    shift
  done

  # main

  ## message is not empty
  if [[ ! -z ${_message} ]]; then
    ## output to screen
    if [[ ${_screen_output} == ${true} ]]; then
      _exit_string=$( ${cmd_echo} ${_date} - ${_message} 2>/dev/null )
      
      # set exit string on failure
      if [[ ${?} != ${exit_ok} ]]; then
        _exit_string=
        (( _error_count++ ))
      fi

    fi

    ## syslog output
    if [[ ! -z ${_remote_server} ]]; then

      # format message output
      if [[ ${_is_json} == ${true} ]]; then
        _message=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.message |=.+ '"${_message}" )

        if [[ ! -z ${RUN_ID} ]]; then
          # add id to message
          _message=$( ${cmd_echo} ${_message} | ${cmd_jq} -c '.id |=.+ "'"${RUN_ID}"'"' )
        fi
      
      else
        if [[ ! -z ${RUN_ID} ]]; then
          # add id to message
          _message=$( ${cmd_echo} ${RUN_ID} - ${_message} )
        fi
      
      fi

      # output message
      ${cmd_logger} --tag ${_syslog_tag} --server ${_remote_server} "${_message}"

      # set exit string on failure
      if [[ ${?} != ${exit_ok} ]]; then
        (( _error_count++ ))
      fi
    
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