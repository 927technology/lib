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
  
  # local variables
  local _err_count=0
  local _exit_code=${exit_warn}
  local _extension=
  local _exit_string=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -g  | --groups )
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
    esac
    shift
  done

  if [[ ! -z ${_group} ]] && [[ ! -z ${_owner} ]] && [[ -d ${_path} ]] && [[ ! -z ${_secrets_provider} ]] ; then
    for file in tls_cert, tls_key; do
      case ${_provider} in
        bitwarden )
          # get config from secrets provider
          _json=$( ${cmd_bws} secret list | ${cmd_jq} -r '.[] | select(.key | startswith("'${file}'"))' | ${cmd_jq} -c )
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
      if [[ ${?} == ${exit_ok} ]] && [[ $( json.validate --json ${_json} ) == ${exit_ok} ]]; then

        # create folder structure
        ${cmd_mkdir} ${_path}/secrets
        ${cmd_chmod} 550 ${_path}/secrets

        for config in $(          ${cmd_echo} ${_json}  | ${cmd_jq} -c '.[]' ); do
          _config_profile=$(      ${cmd_echo} ${config} | ${cmd_jq} -r '.key' ) 
          _config_certificate=$(  ${cmd_echo} ${config} | ${cmd_jq} -r '.value' )

          ${cmd_echo} ${_config_certificate} > ${_path}/secrets/tls.${_extension}

          ${cmd_chown} ${_owner}:${_group}  ${_path}/secrets/tls.${_extension}
          ${cmd_chmod} 600 ${_path}/secrets/${file}.${_extension}
        done
      else
        # oopsie
        (( _err_count++ ))
      fi

  else
    # oopsie
    (( _err_count++ ))
  fi

  # exit status
  [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  #return
  return ${_exit_code}
}