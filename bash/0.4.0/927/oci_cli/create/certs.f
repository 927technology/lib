927.oci_cli.create.certs() {
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
    shell.log --screen --message "CREATE: ${_path_gearmand}/ EXISTS" --tag ${_tag} --remote-server ${LOG_SERVER}

    # create secrets path
    if shell.create.directory --directory ${_path_gearmand}/secrets --group gearmand --mode 600 --owner gearmand ; then
      
      # write ${_path_gearmand}/secrets/${_provider}-${_tenancy}.priv
      for config in "$( ${cmd_echo} ${_json_secrets} | ${cmd_jq} -cr '.[] | select(.key | startswith("key-cloud")).value' )"; do
        _provider=$(    ${cmd_echo} ${config} | ${cmd_jq} -r '.provider'  )
        _tenancy=$(     ${cmd_echo} ${config} | ${cmd_jq} -r '.tenancy'   )

        # create cert file ${_path_gearmand}/secrets/${_provider}-${_tenancy}.priv
        if shell.create.file --group gearmand --mode 600 --owner gearmand --path ${_path_gearmand}/secrets/${_provider}-${_tenancy}.priv; then

          # write cert to ${_path_gearmand}/secrets/${_provider}-${_tenancy}.priv
          ${cmd_echo} ${config} | ${cmd_jq} -r '.cert' > ${_path_gearmand}/secrets/${_provider}-${_tenancy}.priv
        
        else
          (( _error_count++ ))
        fi
      done
    else
      (( _error_count++ ))
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