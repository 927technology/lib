927.secretservice.get.role () {
  # description
  # retrieve the password and/or the password & user from the secrets provider
  # accepts 3 arguments -
  ## -r/--role which is the role of the server
  ## -sp/--secrets-provider which is the service hosting the secrets
  ## -v/--verbose which gives additional output for troubleshooting, output is sent to stderr

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v

  # argument variables
  local _role=
  local _secrets_provider=
  local _verbose=${false}
  
  # local variables
  local _candidate_secret=
  local _candidate_secret_hash=
  local _candidate_user=
  local _configuration_changes=0
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _group=
  local _key=
  local _owner=
  local _running_secret_hash=
  local _running_secret=
  local _secrets_path=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -r  | --role )
        shift
        _role=${1}
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
  
  # main

  # ensure variables are set
  if [[ ! -z ${_role} ]] && [[ ! -z ${_secrets_provider} ]]; then

    # set keys to pull from provider
    case ${_role} in
      cicd )
        _group=naemon
        _keys=(                                                                                     \
          cicd_pass                                                                                 \
          cicd_user                                                                                 \
        )
        _owner=naemon
        _secrets_path=~naemon/secrets
      ;;
      configserver )
        _group=
        _keys=
        _owner=
        _secrets_path=
      ;;
      jobserver )
        _group=naemon
        _keys=(                                                                                     \
          jobserver_pass                                                                            \
        )
        _owner=naemon
        _secrets_path=~naemon/secrets
      ;;
      workerserver )
        _group=naemon
        _keys=(                                                                                     \
          workerserver_pass                                                                         \
        )
        _owner=naemon
        _secrets_path=~naemon/secrets
      ;;
    esac

    # pull secrets from provider
    case ${_secrets_provider} in
      bitwarden )
        # get config from secrets provider
        case ${#_keys[@]} in 
          1 )
            _candidate_secret=$(  ${cmd_bws} secret list | ${cmd_jq} -r '.[] | select(.key == "'${_keys[0]}'").value' )
          ;;
          2 )
            _candidate_user=$(    ${cmd_bws} secret list | ${cmd_jq} -r '.[] | select(.key == "'${_keys[1]}'").value' )
            _candidate_secret=$(  ${cmd_bws} secret list | ${cmd_jq} -r '.[] | select(.key == "'${_keys[0]}'").value' )
            _candidate_secret=${_candidate_user}:${_candidate_secret}
          ;;
        esac
      ;;
    esac

    # output user
    if  [[ ${_verbose} == ${true} ]]; then
      if  [[ ! -z ${_candidate_secret} ]] &&                                                          \
          [[ ${#_keys[@]} == 2 ]]; then
        ${cmd_echo} user:${_user}                                                                     >&2 
      else
        ${cmd_echo} user:**missing**                                                                  >&2
      fi
    fi

    # generate hashes
    if  [[ ! -z ${_candidate_secret} ]]; then
      _candidate_secret_hash=$( ${cmd_echo} ${_candidate_secret}        | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
      
      if [[ -f ${_secrets_path}/${_role}.pwd ]]; then
        _running_secret_hash=$( ${cmd_cat} ${_secrets_path}/${_role}.pwd  | ${cmd_sha256sum} | ${cmd_awk} '{print $1}' )
      fi
    fi

    # output secret hash
    if  [[ ${_verbose} == ${true} ]]; then
      if [[ ! -z ${_candidate_secret_hash} ]]; then
        ${cmd_echo} candidate secret:**${_candidate_secret_hash}**                                    >&2 
        ${cmd_echo} running secret:**${_running_secret_hash}**                                        >&2 
      else
        ${cmd_echo} secret:**missing**                                                                >&2
      fi
    fi


    # verify pwd
    if [[ ! -f ${_secrets_path}/${_role}.pwd ]] ||                                                  \
       [[ ${_running_secret_hash} != ${_candidate_secret_hash} ]]; then

      # verbose output
      if [[ ${_verbose} == ${true} ]]; then
        ${cmd_echo} secrets do not match, creating new
      fi

      # increment change counter
      (( _configuration_changes++ ))
      
      # ensure user name and password are not blank
      if  (                                                                                         \
            [[ ${#_keys[@]} == 1 ]] &&                                                              \
            [[ ! -z ${_candidate_secret} ]]                                                         \
          )                                                                                         \
          ||                                                                                        \
          (                                                                                         \
            [[ ${#_keys[@]} == 2 ]] &&                                                              \
            [[ ! -z ${_candidate_secret} ]] &&                                                      \
            [[ ! -z ${_user} ]]                                                                     \
          ); then

        # create secrets path
        if  [[ ! -d ${_secrets_path} ]]; then
          ${cmd_mkdir} -p ${_secrets_path}

          if [[ ${?} != ${exit_ok} ]]; then
            if [[ ${_verbose} == ${true} ]]; then
              ${cmd_echo} could not create secrets path                                             >&2
            fi
            f
            (( _error_count++ ))
          fi
        fi
        
        # set owner/group on secrets path
        ${cmd_chown} ${_owner}:${_group} ${_secrets_path}
        if [[ ${?} != ${exit_ok} ]]; then
          if [[ ${_verbose} == ${true} ]]; then 
            ${cmd_echo} could not set owner/group on secrets path                                   >&2
          fi

          (( _error_count++ ))
        fi
        
        # set mode on secrets path
        ${cmd_chmod} 770 ${_secrets_path}
        if [[ ${?} != ${exit_ok} ]]; then
          if [[ ${_verbose} == ${true} ]]; then
            ${cmd_echo} could not set mode secrets path                                             >&2
          fi
          
          (( _error_count++ ))
        fi 

        # write password file
        ${cmd_echo} ${_candidate_secret} > ${_secrets_path}/${_role}.pwd

        # set owner, group, and mode for pwd file
        ${cmd_chown} ${_owner}:${_group} ${_secrets_path}/${_role}.pwd
        if [[ ${?} != ${exit_ok} ]]; then
          if [[ ${_verbose} == ${true} ]]; then
            ${cmd_echo} could not set user/group on secret file                                     >&2
          fi
          
          (( _error_count++ ))
        fi

        # set mode on pwd file
        ${cmd_chmod} 600 ${_secrets_path}/${_role}.pwd
        if [[ ${?} != ${exit_ok} ]]; then
          if [[ ${_verbose} == ${true} ]]; then
            ${cmd_echo} could not set mode on secret file                                           >&2
          fi
          
          (( _error_count++ ))
        fi

      else
        # oopsie
        ${cmd_echo} user name or secret is missing                                                  >&2 

        (( _error_count++ ))
      fi
    else
      if [[ ${_verbose} == ${true} ]]; then
        ${cmd_echo} secret path exists and secret is unchanged                                      >&2 
      fi
    fi
  else 
    # oopsie
    if [[ ${_verbose} == ${true} ]]; then
      ${cmd_echo} candidate secret is missing                                                       >&2
    fi 

    (( _error_count++ ))  
  fi

  # verbose output
  if [[ ${_verbose} == ${true} ]]; then
    ${cmd_echo} group:${_group} owner:${_owner} path:${_secrets_path}/${_role}.pwd provider:${_secrets_provider} >&2
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