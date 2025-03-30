927.secretservice.get.tlscert () {
  # description
  # creates oci cli configuration by using the configuration provided
  # accepts 2 arguments -
  ## -p/--path which is the full path to the root folder to place .oci/config file
  ## this is typically the path to a home folder of the service account

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # argument variables
  local _json="{}"
  local _group=
  local _owner=
  local _path=
  local _secrets_provider=
  local _verbose=${false}
  
  # local variables
  local _candidate_secret=
  local _candidate_secret_hash=
  local _err_count=0
  local _exit_code=${exit_warn}
  local _extension=
  local _exit_string=
  local _running_secret=
  local _running_secret_hash=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -g  | --group )
        shift
        _group=${1}
      ;;
      -o  | --owner )
        shift
        _owner=${1}
      ;;
      -p  | --path )
        shift
        _path=${1}
      ;;
      -sp | --secrets-provider )
        shift
        _secrets_provider=${1}
      ;;
      -v  | --verbose )
        _verbose=${true}
      ;;
    esac
    shift
  done

  if  [[ ${_verbose} == ${true} ]]; then
    ${cmd_echo} group:${_group} owner:${_owner} path:${_path} secret:${_secrets_provider}
  fi

  if [[ ! -z ${_group} ]] && [[ ! -z ${_owner} ]] && [[ -d ${_path} ]] && [[ ! -z ${_secrets_provider} ]] ; then
    for file in tls_cert tls_key; do
      _candidate_secret=
      _candidate_secret_hash=
      _json="{}"

      case ${_secrets_provider} in
        bitwarden )
          # get config from secrets provider
          _json=$( ${cmd_bws} secret list | ${cmd_jq} '.[] | select(.key | startswith("'${file}'"))' | ${cmd_jq} -c )
        ;;
      esac

      case ${file} in
        tls_cert )
          _extension=cert
        ;;
        tls_key )
          _extension=key
        ;;
      esac

      # ensure pull and validate are good
      if  [[ ${?} == ${exit_ok} ]] &&                                                               \ 
          [[ $( json.validate --json ${_json} ) == ${exit_ok} ]]; then

          # get candidate secret
          _candidate_secret=$( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.value' )


        # generate hashes
        if  [[ ! -z ${_candidate_secret} ]]; then
          _candidate_secret_hash=$( ${cmd_echo} ${_candidate_secret}              | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
          
          if [[ -f ${_path}/secrets/tls.${_extension} ]]; then
            _running_secret_hash=$( ${cmd_cat} ${_path}/secrets/tls.${_extension} | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
          fi
        fi
        
        
        # output secret hash
        if  [[ ${_verbose} == ${true} ]]; then
          if [[ ! -z ${_candidate_secret_hash} ]]; then
            ${cmd_echo} candidate secret:**${_candidate_secret_hash}**                              >&2 
            ${cmd_echo} running secret:**${_running_secret_hash}**                                  >&2 
          else
            ${cmd_echo} secret:**missing**                                                          >&2
          fi
        fi
        
        # verify secret
        if [[ ! -f ${_path}/secrets/tls.${_extension} ]] ||                                         \
          [[ ${_running_secret_hash} != ${_candidate_secret_hash} ]]; then

          # verbose output
          if [[ ${_verbose} == ${true} ]]; then
            ${cmd_echo} secrets do not match, creating new
          fi

          # increment change counter
          (( _configuration_changes++ ))
        
          if [[ ! -z ${_candidate_secret} ]]; then

            # create secrets path
            if  [[ ! -d ${_path}/secrets/tls.${_extension} ]]; then
              ${cmd_mkdir} -p ${_path}/secrets/tls.${_extension}

              if [[ ${?} != ${exit_ok} ]]; then
                if [[ ${_verbose} == ${true} ]]; then
                  ${cmd_echo} could not create secrets path                                         >&2
                fi
                
                (( _error_count++ ))
              fi
            fi
            
            # set owner/group on secrets path
            ${cmd_chown} ${_owner}:${_group} ${_path}/secrets/tls.${_extension}
            if [[ ${?} != ${exit_ok} ]]; then
              if [[ ${_verbose} == ${true} ]]; then 
                ${cmd_echo} could not set owner/group on secrets path                               >&2
              fi

              (( _error_count++ ))
            fi
            
            # set mode on secrets path
            ${cmd_chmod} 770 ${_path}/secrets/tls.${_extension}
            if [[ ${?} != ${exit_ok} ]]; then
              if [[ ${_verbose} == ${true} ]]; then
                ${cmd_echo} could not set mode secrets path                                         >&2
              fi
              
              (( _error_count++ ))
            fi 

            # output secret
            ${cmd_echo} ${_candidate_secret} > ${_path}/secrets/tls.${_extension}

            # set owner, group, and mode for secret file
            ${cmd_chown} ${_owner}:${_group} ${_path}/secrets/tls.${_extension}
            if [[ ${?} != ${exit_ok} ]]; then
              if [[ ${_verbose} == ${true} ]]; then
                ${cmd_echo} could not set user/group on secret file                                 >&2
              fi
              
              (( _error_count++ ))
            fi

            # set mode on secret file
            ${cmd_chmod} 600 ${_path}/secrets/tls.${_extension}
            if [[ ${?} != ${exit_ok} ]]; then
              if [[ ${_verbose} == ${true} ]]; then
                ${cmd_echo} could not set mode on secret file                                       >&2
              fi
              
              (( _error_count++ ))
            fi
          fi
        fi

      else
        # oopsie
        if [[ ${_verbose} == ${true} ]]; then
          ${cmd_echo} json failed validation                                                        >&2
        fi

        (( _err_count++ ))
      fi
    done
  else
    # oopsie
    (( _err_count++ ))
  fi

  # exit status
  if  [[ ${_error_count} > 0 ]]; then
      if  [[ ${_verbose} == ${true} ]]; then
        ${cmd_echo} errors detected                                                                 >&2
      fi
    _exit_code=${exit_crit}

  elif  [[ ${_configuration_changes} > 0 ]]; then
      if  [[ ${_verbose} == ${true} ]]; then
        ${cmd_echo} configuration changes detected, role server may need to be restarted            >&2
      fi

    _exit_code=${exit_warn}
  else
      if  [[ ${_verbose} == ${true} ]]; then
        ${cmd_echo} no errors and no changes detected                                               >&2
      fi

    _exit_code=${exit_ok}
  fi

  _exit_string=${_exit_code}

  # exit string
  ${cmd_echo} ${_exit_string}

  #return
  return ${_exit_code}
}