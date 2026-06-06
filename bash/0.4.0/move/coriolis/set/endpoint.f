move.coriolis.set.endpoint() {
  # argument variables
  local _name=
  local _profile=
  local _verbose=${true}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _json="{}"
  
  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -e | --endpoint | -n  | --name )
        shift
        _name="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
      -v | --verbose )
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && exit ${exit_crit}

  if [[ ! -z ${_profile} ]]; then

    # get secrets
    move.get.secrets --profile ${_profile}

    # get connect file info
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '[[ .[] | select(( .name == "'"${_profile}"'" ) and .enable == '${true}' ) | .coriolis[] | select( .enable == '${true}' ) ] | .[0] ]' )

    if  [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '. | length' ) > 0 ]]; then

      # unset existing env_vars
      # for env_var in $( set | ${cmd_awk} '{FS="="} /^CORIOLIS_/ {print $1}' ); do 
      for env_var in OS_PROJECT_DOMAIN_NAME OS_USER_DOMAIN_NAME OS_PROJECT_NAME OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_AUTH_URL OS_INTERFACE OS_ENDPOINT_TYPE OS_IDENTITY_API_VERSION OS_REGION_NAME OS_AUTH_PLUGIN OS_CACERT; do    
        if [[ ! -z ${env_var} ]]; then
          unset ${env_var}

          if [[ ${?} == ${exit_ok} ]]; then
            [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), ${env_var} unset"

          else
            [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), ${env_var} unset"
            (( _error_count++ ))

          fi

        else
          [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), ${env_var} not set"

        fi
      
      done

      # set credentials
      export CORIOLIS_NAME=$( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), CORIOLIS_NAME: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_PROJECT_DOMAIN_NAME=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.project.domain.name' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_PROJECT_DOMAIN_NAME: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.project.domain.name' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}} - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_USER_DOMAIN_NAME=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.user.domain.name' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_USER_DOMAIN_NAME: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.user.domain.name' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_PROJECT_NAME=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].project.name' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_PROJECT_NAME: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].project.name' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_TENANT_NAME=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].tenant.name' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_TENANT_NAME: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].tenant.name' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_TENANT_NAME export"
        (( _error_count++ ))

      fi


      export OS_USERNAME=$(                                                            \
        move.list.secrets                                                               \
          --secret $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].auth.vault.credential.name' ) \
          --output username                                                             \
      )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_USERNAME: $( move.list.secrets --secret $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].auth.vault.credential.name' ) --output username ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_PASSWORD=$(                                                            \
        move.list.secrets                                                               \
          --secret $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].auth.vault.credential.name' ) \
          --output password                                                            \
      )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_PASSWORD: ************** exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_AUTH_URL=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.url' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_AUTH_URL: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.url' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_INTERFACE=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.interface' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_INTERFACE: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.interface' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_ENDPOINT_TYPE=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.endpoint_type' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_ENDPOINT_TYPE: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.endpoint_type' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}} - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_IDENTITY_API_VERSION=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.version' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_IDENTITY_API_VERSION: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].api.version' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_REGION_NAME=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].region' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_REGION_NAME: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].region' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_AUTH_PLUGIN=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.plugin' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_AUTH_PLUGIN: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].auth.plugin' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

      export OS_CACERT=$( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].cert' )
      if [[ ${?} == ${exit_ok} ]]; then
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), OS_CACERT: $( ${cmd_echo} "${_json}"  | ${cmd_jq} -r '.[0].cert' ) exported"

      else
        [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )"
        (( _error_count++ ))

      fi

    else
      [[ ${_verbose} == ${true} ]] && shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), syntax"
      (( _error_count++ ))

    fi

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}