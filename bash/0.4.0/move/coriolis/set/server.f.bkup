move.coriolis.set.server() {
  # local variables
  local _json=

  # argument variables
  local _name=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -n  | --name )
        shift
        _name="${1}"
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_name} ]]; then
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '.[] | select( .name == "'"${MOVE_PROFILE}"'" ).coriolis[] | if(( .endpoint == "'"${_name}"'" ) and .enable == '${true}' ) then . else empty end' )
    
    # set credentials
    if  [[ ! -z "${_json}" ]]; then
      # unset existing env_vars
      for env_var in $( set | ${cmd_awk} '{FS="="} /^OS_/ {print $1}' ); do 
        unset ${env_var}
      done
      
      # set env_vars
      export CORIOLIS_NAME=${_name}
      export OS_PROJECT_DOMAIN_NAME=$( ${cmd_echo} "${_json}"   | ${cmd_jq} -r '.auth.project.domain.name' )
      export OS_USER_DOMAIN_NAME=$( ${cmd_echo} "${_json}"      | ${cmd_jq} -r '.project.name'             )
      export OS_TENANT_NAME=$( ${cmd_echo} "${_json}"           | ${cmd_jq} -r '.tenant.name'              )
      export OS_USERNAME=$( ${cmd_echo} "${_json}"              | ${cmd_jq} -r '.auth.user.name'           )
      export OS_PASSWORD=$( ${cmd_echo} "${_json}"              | ${cmd_jq} -r '.auth.user.password'       )
      export OS_AUTH_URL=$( ${cmd_echo} "${_json}"              | ${cmd_jq} -r '.api.url'                  )  
      export OS_INTERFACE=$( ${cmd_echo} "${_json}"             | ${cmd_jq} -r '.api.interface'            )
      export OS_ENDPOINT_TYPE=$( ${cmd_echo} "${_json}"         | ${cmd_jq} -r '.api.endpoint_type'        )
      export OS_IDENTITY_API_VERSION=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.api.version'              )
      export OS_REGION_NAME=$( ${cmd_echo} "${_json}"           | ${cmd_jq} -r '.region'                   ) 
      export OS_AUTH_PLUGIN=$( ${cmd_echo} "${_json}"           | ${cmd_jq} -r '.auth.plugin'              )
      export OS_CACERT=$( ${cmd_echo} "${_json}"                | ${cmd_jq} -r '.cert'                     )
  
  
  
  
  
  
  
      # export CORIOLIS_NAME=${_name}
      # export OS_PROJECT_DOMAIN_NAME=$( ${cmd_cat} /usr/local/etc/move/connect.json  | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").auth.project.domain.name' )
      # export OS_USER_DOMAIN_NAME=$( ${cmd_cat} /usr/local/etc/move/connect.json     | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").auth.user.domain.name'    )
      # export OS_PROJECT_NAME=$( ${cmd_cat} /usr/local/etc/move/connect.json         | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").project.name'             )
      # export OS_TENANT_NAME=$( ${cmd_cat} /usr/local/etc/move/connect.json          | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").tenant.name'              )
      # export OS_USERNAME=$( ${cmd_cat} /usr/local/etc/move/connect.json             | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").auth.user.name'           )
      # export OS_PASSWORD=$( ${cmd_cat} /usr/local/etc/move/connect.json             | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").auth.user.password'       )
      # export OS_AUTH_URL=$( ${cmd_cat} /usr/local/etc/move/connect.json             | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").api.url'                  )  
      # export OS_INTERFACE=$( ${cmd_cat} /usr/local/etc/move/connect.json            | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").api.interface'            )
      # export OS_ENDPOINT_TYPE=$( ${cmd_cat} /usr/local/etc/move/connect.json        | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").api.endpoint_type'        )
      # export OS_IDENTITY_API_VERSION=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").api.version'              )
      # export OS_REGION_NAME=$( ${cmd_cat} /usr/local/etc/move/connect.json          | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").region'                   ) 
      # export OS_AUTH_PLUGIN=$( ${cmd_cat} /usr/local/etc/move/connect.json          | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").auth.plugin'              )
      # export OS_CACERT=$( ${cmd_cat} /usr/local/etc/move/connect.json               | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").cert'                     )

    fi
  fi

  # exit
  return ${_exit_code}
}