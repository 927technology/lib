move.list.secrets() {
  # local variables
  local _json="${MOVE_SECRETS}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _secret=
  local _output=
  local _verbose=${false}

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -o | --output )
        shift
        _output="${1}"
      ;;      
      -s | --secret )
        shift
        _secret="${1}"
      ;;
      -v | --verbose )
        _verbose=${true}
      ;;
     esac
    shift
  done

  # main
  if  [[ ! -z ${_secret}  ]]  &&  \
      [[ ! -z ${_json}        ]]; then

    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[] | select ( .name == "'"${_secret}"'" )' )

    shell.log "${FUNCNAME} - [SECRET]    Validating"

    # empty json
    if  [[ ${_json} != "{}"  ]]; then
      shell.log "${FUNCNAME} - [SECRET]    Validating: Not Empty"

      # bad json
      if  [[ $( ${cmd_echo} "${_json}" | is_json ) == ${true}  ]]; then
        shell.log "${FUNCNAME} - [SECRET]    Validating: Format Correct"

        # output
        if [[ ! -z ${_output} ]]; then
          case ${_output} in
            name            ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .name ) then .name else empty end'                                                               ;;
            password        ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .secret.password ) then .secret.password else empty end'                                                               ;;
            username        ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .secret.username ) then .secret.username else empty end'                                                               ;;

          esac
        else
          # ${cmd_echo} ${_json} | ${cmd_jq} 
          ${cmd_echo} ${_json} | ${cmd_jq} -c

        fi # output check
      else
        shell.log "${FUNCNAME} - [ERROR]    Validating: Format Incorrect"
        (( _error_count++ ))

      fi # end bad json check
    
    else
      shell.log "${FUNCNAME} - [ERROR]    Validating: Empty"
      (( _error_count++ ))

    fi # end empty json

  else
      shell.log "${FUNCNAME} - [ERROR]    Validating: Missing Credential or Empty Secrets"
      (( _error_count++ ))

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}