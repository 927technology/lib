rapid.get.details() {
  # local variables
  local _json="{}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _alternate_id=
  local _filter=
  local _key=
  local _output=
  local _secret=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -a | --alternate-id )
        shift
        [[ ! -z "${?}" ]] && _alternate_id="${1}" || return ${exit_crit}
      ;;
      -f | --filter )
        shift
        _filter="${1}"
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
     esac
    shift
  done

  # main
  if  [[ ! -z ${_alternate_id}  ]] && \
      [[ ! -z ${_key}           ]] && \
      [[ ! -z ${_secret}        ]]; then

    shell.log "${FUNCNAME} - [SECRET]    Fetching Details"

    # query api
    _json=$(                                                            \
      ${cmd_curl}                                                       \
        -s                                                              \
        -X GET                                                          \
        -H "accept: application/json"                                   \
        -H "Authorization: Bearer $( rapid.get.token --key ${_key} --secret ${_secret} --output access_token )"   \
        "https://rapid.cerner.com:8243/vault-readonly-api/v1/Read/CredentialDetails?alternateID=${_alternate_id}" \
        | ${cmd_jq} -c '.CredentialDetails[]'
    ) 

    # filter
    if [[ ! -z ${_filter} ]]; then
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} '. | select( .MetadataEntries[].MetadataEntryValue | contains( "'"${_filter}"'" ))' )

    fi

    # change output
    if [[ ! -z ${_output} ]]; then
      case ${_output} in
        id              ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .CredentialID ) then .CredentialID else empty end'                                                               ;;
        username        ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .Username ) then .Username else empty end'                                                               ;;

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