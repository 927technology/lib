move.coriolis.set.endpoint() {
  # global variables
  declare -g OS_PROJECT_DOMAIN_NAME=
  declare -g OS_USER_DOMAIN_NAME=
  declare -g OS_PROJECT_NAME=
  declare -g OS_TENANT_NAME=
  declare -g OS_USERNAME=
  declare -g OS_PASSWORD=
  declare -g OS_AUTH_URL=
  declare -g OS_INTERFACE=
  declare -g OS_ENDPOINT_TYPE=
  declare -g OS_IDENTITY_API_VERSION=
  declare -g OS_REGION_NAME=
  declare -g OS_AUTH_PLUGIN=
  declare -g OS_CACERT= 

  # argument variables
  local _name=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _json="{}"
  
  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -e | --endpoint | -h | --host | -n  | --name )
        shift
        _name="${1}"
      ;;
    esac
    shift
  done

  # main
  if [[ ! -z ${MOVE_PROFILE} ]]; then
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '[[ .[] | select(( .name == "'"${MOVE_PROFILE}"'" ) and .enable == '${true}' ) ] | [ .[0].coriolis[] | select(( .endpoint == "'"${_name}"'") and .enable == 1 ) ] | .[0] ]' )
    if  [[ ! -z ${_name} ]]             && \
        [[ ! -z ${MOVE_PROFILE} ]]   && \
        [[ $( ${cmd_echo} "${_json}" | ${cmd_jq} '. | length' ) > 0 ]]; then

      
      # unset existing env_vars
      # for env_var in $( set | ${cmd_awk} '{FS="="} /^CORIOLIS_/ {print $1}' ); do 
      for env_var in OS_PROJECT_DOMAIN_NAME OS_USER_DOMAIN_NAME OS_PROJECT_NAME OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_AUTH_URL OS_INTERFACE OS_ENDPOINT_TYPE OS_IDENTITY_API_VERSION OS_REGION_NAME OS_AUTH_PLUGIN OS_CACERT; do    
        if [[ ! -z ${env_var} ]]; then
          unset ${env_var}
          if [[ ${?} == ${exit_ok} ]]; then
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, ${env_var} unset"

          else
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, ${env_var} unset"
            (( _error_count++ ))

          fi

        else
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, ${env_var} not set"

        fi
      
      done

      # set credentials
      export CORIOLIS_NAME=${_name}
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, CORIOLIS_NAME exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, CORIOLIS_NAME export"
        (( _error_count++ ))

      fi

      export OS_PROJECT_DOMAIN_NAME=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.project.domain.name'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_PROJECT_DOMAIN_NAME exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}} - [FAILURE] End Point ${_name}, OS_PROJECT_DOMAIN_NAME export"
        (( _error_count++ ))

      fi

      export OS_USER_DOMAIN_NAME=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.user.domain.name'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_USER_DOMAIN_NAME exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_USER_DOMAIN_NAME export"
        (( _error_count++ ))

      fi

      export OS_PROJECT_NAME=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].project.name'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_PROJECT_NAME exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_PROJECT_NAME export"
        (( _error_count++ ))

      fi

      export OS_TENANT_NAME=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].tenant.name'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_TENANT_NAME exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_TENANT_NAME export"
        (( _error_count++ ))

      fi

      export OS_USERNAME=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.user.name'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_USERNAME exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_USERNAME export"
        (( _error_count++ ))

      fi

      export OS_PASSWORD=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.user.password'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_PASSWORD exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_PASSWORD export"
        (( _error_count++ ))

      fi

      export OS_AUTH_URL=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.url'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_AUTH_URL exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_AUTH_URL export"
        (( _error_count++ ))

      fi

      export OS_INTERFACE=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.interface'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_INTERFACE exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_INTERFACE export"
        (( _error_count++ ))

      fi

      export OS_ENDPOINT_TYPE=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.endpoint_type'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_ENDPOINT_TYPE exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}} - [FAILURE] End Point ${_name}, OS_ENDPOINT_TYPE export"
        (( _error_count++ ))

      fi

      export OS_IDENTITY_API_VERSION=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.version'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_IDENTITY_API_VERSION exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_IDENTITY_API_VERSION export"
        (( _error_count++ ))

      fi

      export OS_REGION_NAME=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].region'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_REGION_NAME exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_REGION_NAME export"
        (( _error_count++ ))

      fi

      export OS_AUTH_PLUGIN=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.plugin'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_AUTH_PLUGIN exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_AUTH_PLUGIN export"
        (( _error_count++ ))

      fi

      export OS_CACERT=$(      ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].cert'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, OS_CACERT exported"

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, OS_CACERT export"
        (( _error_count++ ))

      fi

    else
      shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, syntax"
      (( _error_count++ ))

    fi

  else
      shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point ${_name}, MOVE_PROFILE not set"

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}