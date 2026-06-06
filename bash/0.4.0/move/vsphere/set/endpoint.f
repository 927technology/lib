move.vsphere.set.endpoint() {
  # variables
  local _json="{}"

  # argument variables
  local _name=
  local _profile=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _function=move.vsphere.set.endpoint

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -n  | --name | -e | --endpoint )
        shift
        _name="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  if [[ ! -z ${_profile} ]]; then

    # get secrets
    move.get.secrets --profile ${_profile}

    # get connect file info
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '[[ .[] | select(( .name == "'"${_profile}"'" ) and .enable == '${true}' ) | .vsphere[] | select( .enable == '${true}' ) ] | .[0] ]' )

    if  [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '. | length' ) > 0 ]]; then
      
      # unset existing env_vars
      # for env_var in $( set | ${cmd_awk} '{FS="="} /^VSPHERE_/ {print $1}' ); do 
      for env_var in VSPHERE_NAME VSPHERE_USER VSPHERE_PASSWORD VSPHERE_SERVER; do    
        if [[ ! -z ${env_var} ]]; then
          unset ${env_var}
          if [[ ${?} == ${exit_ok} ]]; then
            shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${env_var} unset"

          else
            shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point: ${env_var} unset"
            (( _error_count++ ))

          fi

        else
          shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${env_var} not set"
            (( _error_count++ ))

        fi
      
      done

      # set credentials
      export VSPHERE_NAME=$( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), VSPHERE_NAME: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ) exported"
        (( _error_count++ ))

      else
        shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), VSPHERE_NAME export"
        (( _error_count++ ))

      fi




      export VSPHERE_USER=$(                                                            \
        move.list.secrets                                                               \
          --secret $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].auth.vault.credential.name' ) \
          --output username                                                             \
      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), VSPHERE_USER: $( move.list.secrets --secret $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].auth.vault.credential.name' ) --output username ) exported"
        (( _error_count++ ))

      else
        shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), VSPHERE_USER export"
        (( _error_count++ ))

      fi

      # export VSPHERE_USER=$(      ${cmd_echo} ${_json}  | ${cmd_jq} -r '.[0].user'      )
      # if [[ ${?} == ${exit_ok} ]]; then
      #   shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${_name}, VSPHERE_USER exported"
      #   (( _error_count++ ))

      # else
      #   shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point: ${_name}, VSPHERE_USER export"
      #   (( _error_count++ ))

      # fi




      export VSPHERE_PASSWORD=$(                                                            \
        move.list.secrets                                                               \
          --secret $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].auth.vault.credential.name' ) \
          --output password                                                             \
      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), VSPHERE_PASSWORD: ************** exported"
        (( _error_count++ ))

      else
        shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), VSPHERE_PASSWORD export"
        (( _error_count++ ))

      fi

      # export VSPHERE_PASSWORD=$(  ${cmd_echo} ${_json}  | ${cmd_jq} -r '.[0].password'  )
      # if [[ ${?} == ${exit_ok} ]]; then
      #   shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${_name}, VSPHERE_PASSWORD exported"
      #   (( _error_count++ ))

      # else
      #   shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point: ${_name}, VSPHERE_PASSWORD export"
      #   (( _error_count++ ))

      # fi








      export VSPHERE_SERVER=$(    ${cmd_echo} ${_json}  | ${cmd_jq} -r '.[0].server'    )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), VSPHERE_SERVER: $( ${cmd_echo} ${_json}  | ${cmd_jq} -r '.[0].server' ) exported"
        (( _error_count++ ))

      else
        shell.log "${FUNCNAME}(${_profile}) - [FAILURE] End Point: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.[0].endpoint' ), VSPHERE_SERVER export"
        (( _error_count++ ))

      fi


    else
      shell.log "${FUNCNAME}(${_profile}) - [FAILURE] syntax"
      (( _error_count++ ))

    fi

  else
      shell.log "${FUNCNAME}(${_profile}) - [FAILURE] MOVE_PROFILE not set"

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}