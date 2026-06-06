rapid.get.credentials() {
  # local variables
  local _bearer_token=
  local _json="{}"
  local _json_credential="{}"

  # control variables
  local _count=0
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local credential=

  # argument variables
  local _alternate_id=
  # local _credential_id=
  # local _credential_ids=
  local _filter=
  local _key=
  local _output=
  local _secret=
  local _verbose=${false}

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -a | --alternate-id )
        shift
        [[ ! -z "${?}" ]] && _alternate_id="${1}" || return ${exit_crit}
      ;;
      # -c | --credential-id )
      #   shift
      #   ${cmd_echo} "${1}" | is_integer >/dev/null 2>&1 && _credential_ids="${1}" || return ${exit_crit} 
      # ;;
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
      -v | --verbose )
        _verbose=${true}
      ;;
     esac
    shift
  done

  # main
  if  ( [[ ! -z ${_credential_ids}  ]]  ||  \
        ( [[ ! -z ${_alternate_id}  ]]  &&  \
          [[ ! -z ${_filter}        ]]      \
        )                                   \
      )                                 &&  \
      [[ ! -z ${_key}           ]]      &&  \
      [[ ! -z ${_secret}        ]]; then

    shell.log "${FUNCNAME} - [SECRET]    Fetching Credential"

    _bearer_token=$( rapid.get.token --key ${_key} --secret ${_secret} --output access_token )

    if  [[   -z ${_credential_ids}  ]]  &&  \
        ( [[ ! -z ${_alternate_id}  ]]  &&  \
          [[ ! -z ${_filter}        ]]      \
        ); then
      _json_details=$( rapid.get.details --alternate-id ${_alternate_id} --filter ${_filter} --key ${_key} --secret ${_secret} )

    fi 

    if  [[ ! -z ${_bearer_token}    ]]; then
      for json_detail in $( ${cmd_echo} ${_json_details} | ${cmd_jq} -c '.[]' ); do
        _json_credential="{}"

        # query api
        _json_credential=$(
          ${cmd_curl}                                                       \
            -s                                                              \
            -X GET                                                          \
            -H "accept: application/json"                                   \
            -H "Authorization: Bearer ${_bearer_token}"                     \
            "https://rapid.cerner.com:8243/vault-readonly-api/v1/Read/CredentialPassword?credentialID=$( ${cmd_echo} ${json_detail} | ${cmd_jq} -r '.CredentialID' )"
        )

        # credential id
        _json=$(                                                                \
          json.set                                                              \
            --json ${_json}                                                     \
            --key .detail[${_count}].id                                         \
            --value $(                                                          \
              ${cmd_echo} ${json_detail} | ${cmd_jq} '.CredentialID'            \
            )                                                                   \
        )

        # credential name
        _json=$(                                                                \
          json.set                                                              \
            --json ${_json}                                                     \
            --key .detail[${_count}].name                                       \
            --value $(                                                          \
              ${cmd_echo} ${json_detail} | ${cmd_jq} '.MetadataEntries[0].MetadataEntryValue' \
            )                                                                   \
        )
        
        # secret password
        _json=$(                                                                \
          json.set                                                              \
            --json ${_json}                                                     \
            --key .detail[${_count}].secret.password                            \
            --value $(                                                          \
              ${cmd_echo} ${_json_credential} | ${cmd_jq} '.Password'           \
            )                                                                   \
        )

        # secret username
        _json=$(                                                                \
          json.set                                                              \
            --json ${_json}                                                     \
            --key .detail[${_count}].secret.username                            \
            --value $(                                                          \
              ${cmd_echo} ${_json_credential} | ${cmd_jq} '.Username'           \
            )                                                                   \
        )

        # secret status code
        _json=$(                                                                \
          json.set                                                              \
            --json ${_json}                                                     \
            --key .detail[${_count}].secret.status.code                         \
            --value $(                                                          \
              ${cmd_echo} ${_json_credential} | ${cmd_jq} '.Status.StatusCode'  \
            )                                                                   \
        )

        # secret status message
        _json=$(                                                                \
          json.set                                                              \
            --json ${_json}                                                     \
            --key .detail[${_count}].secret.status.message                      \
            --value $(                                                          \
              ${cmd_echo} ${_json_credential} | ${cmd_jq} '.Status.StatusMessage' \
            )                                                                   \
        )

        (( _count++ ))
        
      done # json detail

      # change output
      if [[ ! -z ${_output} ]]; then
        case ${_output} in
          username        ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( detail[].secret.username ) then detail[].username else empty end'                                                               ;;
          password        ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( detail[].secret.password ) then detail[].secret.password else empty end'                                                               ;;
          status_code     ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( detail[].secret.status.code ) then detail[].secret.status.code else empty end'                                             ;;
          status_message  ) ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( detail[].secret.status.message ) then detail[].secret.status.message else empty end'                                       ;;

        esac

      else
        ${cmd_echo} ${_json} | ${cmd_jq} -c '.detail'

      fi # output check


    else
      (( _error_count++))
      ${cmd_echo} "[]"
  
    fi # bearer token check
  else
    ${cmd_echo} "[]"

  fi # variable check

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}