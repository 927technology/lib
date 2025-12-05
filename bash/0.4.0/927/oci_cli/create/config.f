927.oci_cli.create.config() {
  # description

  # argument variables
  local _json_secrets="{}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _path_gearmand=
  local _tag=927.oci.get.config

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in 
      -s | --secrets )
        shift
        _json_secrets="${1}"
      ;;
    esac
    shift
  done

  # main
  if  [[ -d ${_path_gearmand}/ ]]; then
    shell.log --screen --message "CREATING: ${_path_gearmand}/ EXISTS" --tag ${_tag} --remote-server ${LOG_SERVER}

    # create ${_path_gearmand}/.oci
    if shell.create.directory --directory ${_path_gearmand}/.oci --group gearmand --mode 600 --owner gearmand; then

      # create ${_path_gearmand}/.oci/config
      if shell.create.file --group gearmand --mode 600 --owner gearmand --path ${_path_gearmand}/.oci/config; then

        # zero out file ${_path_gearmand}/.oci/config
        if > ${_path_gearmand}/.oci/config; then
          shell.log --screen --message "ZEROING: ${_path_gearmand}/.oci/config SUCCESS" --tag ${_tag} --remote-server ${LOG_SERVER}
        else
          shell.log --screen --message "ZEROING: ${_path_gearmand}/.oci/config FAILURE" --tag ${_tag} --remote-server ${LOG_SERVER}
        fi

        # write ${_path_gearmand}/.oci/config
        for config in "$( ${cmd_echo} ${_json_secrets} | ${cmd_jq} -cr '.[] | select(.key | startswith("config-cloud")).value' )"; do
          _fingerprint=$( ${cmd_echo} ${config} | ${cmd_jq} -r '.[].fingerprint' )
          _keyfile=$(     ${cmd_echo} ${config} | ${cmd_jq} -r '.[].keyfile'     )
          _profile=$(     ${cmd_echo} ${config} | ${cmd_jq} -r '.[].profile'     )
          _provider=$(    ${cmd_echo} ${config} | ${cmd_jq} -r '.[].provider'    )
          _region=$(      ${cmd_echo} ${config} | ${cmd_jq} -r '.[].region'      )
          _tenancy=$(     ${cmd_echo} ${config} | ${cmd_jq} -r '.[].tenancy'     )
          _tenancy_id=$(  ${cmd_echo} ${config} | ${cmd_jq} -r '.[].tenancy_id'  )
          _user=$(        ${cmd_echo} ${config} | ${cmd_jq} -r '.[].user'        )
          
          # write config stanza to ${_path_gearmand}/.oci/config
          shell.log --screen --message "WRITING: ${_path_gearmand}/.oci/config" --tag ${_tag} --remote-server ${LOG_SERVER}
          ${cmd_cat} << EOF.config >> ${_path_gearmand}/.oci/config
[${_profile}]
user=${_user}
fingereprint=${_fingerprint}
tenancy=${_tenancy}
region=${_region}
keyfile=${_path_gearmand}/secrets/${_provider}-${_tenancy}.priv

EOF.config
          done
      else
        (( _error_count++ ))
      fi
    else
      (( _error_count++ ))
    fi
  else
    (( _error_count++ ))
  fi

  # exit
  # set _exit_code
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit} 
  
  # print non-zero length _exit_string to screen
  [[ ! -z ${_exit_string} ]] && ${cmd_echo} ${_exit_string}
  
  # return _exit_code
  return ${_exit_code}
}