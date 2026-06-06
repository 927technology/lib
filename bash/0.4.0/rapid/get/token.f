rapid.get.token() {
  # local variables
  local _json="{}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _environment=prod
  local _key=
  local _output=
  local _secret=
  local _type=client

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -e | --environment )
        shift
        case $( ${cmd_echo} "${1}" | lcase ) in 
          prod | staging ) _environment=$( ${cmd_echo} "${1}" | lcase ) ;;
          * ) return ${exit_crit} ;;
        esac
      ;;
      -k | --key )
        shift
        _key="${1}"
      ;;
      -o | --output )
        shift
        _output="${1}"
      ;;
      -s | --secret )
        shift
        _secret="${1}"
      ;;
      -t | --type )
        shift
        case $( ${cmd_echo} "${1}" | lcase ) in 
          client | jwt | saml ) _type=$( ${cmd_echo} "${1}" | lcase ) ;;
          * ) return ${exit_crit} ;;
        esac
      ;;
     esac
    shift
  done

  # main
  if  [[ ! -z ${_key}     ]] && \
      [[ ! -z ${_secret}  ]] && \
      [[ ! -z ${_type}    ]]; then

    shell.log "${FUNCNAME} - [SECRET]    Fetching Bearer Token"

    case ${_type} in
      client )
        _json=$(                                                    \
          ${cmd_curl}                                               \
            -s                                                      \
            -k                                                      \
            -X POST                                                 \
            -u ${_key}:${_secret}                                   \
            -d 'grant_type=client_credentials&validity_period=3600' \
            -H 'Content-Type: application/x-www-form-urlencoded'    \
            https://rapid.cerner.com:8243/token | ${cmd_jq} -c
        )
      ;;
      saml )
        # not implemented
        _json="{}"
      ;;
      jwt )
        # not implemented
        _json="{}"
      ;;
    esac

    if [[ ! -z ${_output} ]]; then
      case ${_output} in
        access_token | token  ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .access_token ) then .access_token else empty end'                                                                ;;
        scope                 ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .scope ) then .scope else empty end'                                                                ;;
        token_type | type     ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .token_type ) then .token_type else empty end'                                                                ;;
        expires_in | expires  ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .expires_in ) then .expires_in else empty end'                                                                ;;

      esac
    else
      ${cmd_echo} ${_json} | ${cmd_jq} -sc

    fi

  else
    ${cmd_echo} ${_json} | ${cmd_jq} -sc

  fi  

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}