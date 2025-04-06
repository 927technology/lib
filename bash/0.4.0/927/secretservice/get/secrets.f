927.secretservice.get.secrets () {
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

  # because IFS sucks
  IFS=$'\n'

  # argument variables
  local _jobserver_pass=
  local _group=
  local _owner=
  local _path=
  local _secrets_provider=
  local _verbose=${false}
  
  # local variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _json="{}"
  local _secret_json="{}"
  local _secret_paths_count=0
  local _secrets_count=0
  local _secrets_json="{}"

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
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
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.name    |=.+ "'"${_secrets_provider}"'"' )

  if [[ ! -z ${_secrets_provider} ]]; then

    # query provider
    case ${_secrets_provider} in
      bitwarden )
        # get config from secrets provider
        _secrets_json=$( ${cmd_bws} secret list | ${cmd_jq} -c )
      ;;
    esac

    # add pull status to json
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.pull |=.+ '${?} )


    # parse secret payload
    for secret in $( ${cmd_echo} "${_secrets_json}" | ${cmd_jq} -c '.[]' ); do
      # reset loop variables
      _group=
      _owner=
      _key=
      _roles=
      _type=
      _path=
      _secret_paths_count=0
      _secret_json="{}"



      # get key
      _key=$( ${cmd_echo} ${secret} | ${cmd_jq} -r '.key' )
      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))

      # get value
      _value=$( ${cmd_echo} ${secret} | ${cmd_jq} -r '.value' )
      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))

      # determine who has access to each key
      case ${_key} in
        cicd* )
          _roles=(              \
            worker              \
          )
          _type=secret
        ;;
        config* )
          _roles=(              \
            worker              \
          )
          _type=secret
        ;;
        job_pass )
          _roles=(              \
            management          \
            job                 \
          )
          _type=secret
        ;;
        key* )
          _roles=(              \
            worker              \
          )
          _type=secret
        ;;
        secret_ssh* )
          _roles=(              \
            secret            \
          )     
          _type=ssh_key
        ;;
        tls* )
          _roles=(              \
            web                 \
          )
          _type=secret
        ;;
        worker_pass )
          _roles=(              \
            job                 \
            worker              \
          )     
          _type=secret
        ;;

      esac

      for role in ${_roles[@]}; do
        case ${role} in
          secret )
            _path=/etc/ssh/
          ;;
          * )
            _path=/ops/${role}/${_type}
          ;;
        esac

        # create secret path
        if [[ ! -d ${_path} ]]; then
          ${cmd_mkdir} -p ${_path}
          [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
        fi

        # set owner:group on secret path
        case ${role} in 
          cicd )
            _group=root
            _owner=nts_cicd
          ;;
          job )
            _group=root
            _owner=nts_job
          ;;
          management )
            _group=root
            _owner=nts_ms
          ;;
          secret )
            _group=root
            _owner=root
          ;;
          web )
            _group=root
            _owner=nts_web
          ;;
          worker )
            _group=root
            _owner=nts_worker
          ;;
        esac


        # write secret
        case ${role} in 
          secret )
            case ${_key} in
              secret_ssh_rsa )
                ${cmd_echo} "${_value}" > ${_path}/ssh_host_rsa_key
              ;;
              secret_ssh_rsa_pub )
                ${cmd_echo} "${_value}" > ${_path}/ssh_host_rsa_key.pub
              ;;
            esac
          ;;
          * )
            ${cmd_echo} "${_value}" > ${_path}/${_key}
          ;;
        esac
        [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))

        # set owner:group and mode on secrets
        ${cmd_chown} -R ${_owner}:${_group} ${_path}
        
        case ${role} in
          secret )
            ${cmd_chmod} 600 ${_path}/ssh_host_rsa_key
          ;;
          * )
            ${cmd_chmod} -R 640 ${_path}
          ;;
        esac

        # add secret status to json
        _secret_json=$( ${cmd_echo} ${_secret_json} | ${cmd_jq} -c '.paths['${_secret_paths_count}'].role           |=.+ "'"${role}"'"' )
        _secret_json=$( ${cmd_echo} ${_secret_json} | ${cmd_jq} -c '.paths['${_secret_paths_count}'].path           |=.+ "'"${_path}"'"' )
        _secret_json=$( ${cmd_echo} ${_secret_json} | ${cmd_jq} -c '.paths['${_secret_paths_count}'].group          |=.+ "'"${_group}"'"' )
        _secret_json=$( ${cmd_echo} ${_secret_json} | ${cmd_jq} -c '.paths['${_secret_paths_count}'].owner          |=.+ "'"${_owner}"'"' )

        (( _secret_paths_count++ ))
      done

      # add values to secret json
      _secret_json=$( ${cmd_echo} ${_secret_json} | ${cmd_jq} -c '.key            |=.+ "'"${_key}"'"' )
      _secret_json=$( ${cmd_echo} ${_secret_json} | ${cmd_jq} -c '.type           |=.+ "'"${_type}"'"' )

      # add secret to output json
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secrets['${_secrets_count}']  |=.+ '"${_secret_json}" )

      (( _secrets_count++ ))
    done
    
    # add error count to exit string
    _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.error_count   |=.+ '${_error_count} )
  fi

  # exit status
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.secret.exit    |=.+ '${_exit_code} )
  _exit_string=$( ${cmd_echo} ${_json} | ${cmd_jq} -c )

  # exit string
  ${cmd_echo} ${_exit_string}

  #return
  return ${_exit_code}
}