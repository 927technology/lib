move.vsphere.set.endpoint() {
  # global variables
  declare -g VSPHERE_USER=
  declare -g VSPHERE_PASSWORD=
  declare -g VSPHERE_USER=

  # argument variables
  local _json=
  local _name=

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
    esac
    shift
  done

  # main
  if [[ ! -z ${MOVE_PROFILE} ]]; then
    _json=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -c '[[ .[] | select(( .name == "'"${MOVE_PROFILE}"'" ) and .enable == '${true}' ) ] | [ .[0].vsphere[] | select(( .endpoint == "'"${_name}"'" ) and .enable == '${true}' ) ] | .[0] ]' )

    if  [[ ! -z ${_name} ]]             && \
        [[ ! -z ${MOVE_PROFILE} ]]   && \
        [[ $( ${cmd_echo} ${_json} | ${cmd_jq} '. | length' ) > 0 ]]; then

      
      # unset existing env_vars
      # for env_var in $( set | ${cmd_awk} '{FS="="} /^VSPHERE_/ {print $1}' ); do 
      for env_var in VSPHERE_NAME VSPHERE_USER VSPHERE_PASSWORD VSPHERE_SERVER; do    
        if [[ ! -z ${env_var} ]]; then
          unset ${env_var}
          if [[ ${?} == ${exit_ok} ]]; then
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, ${env_var} unset"

          else
            shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point: ${_name}, ${env_var} unset"
            (( _error_count++ ))

          fi

        else
          shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, ${env_var} not set"
            (( _error_count++ ))

        fi
      
      done

      # set credentials
      export VSPHERE_NAME=${_name}
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, VSPHERE_NAME exported"
        (( _error_count++ ))

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point: ${_name}, VSPHERE_NAME export"
        (( _error_count++ ))

      fi

      export VSPHERE_USER=$(      ${cmd_echo} ${_json}  | ${cmd_jq} -r '.[0].user'      )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, VSPHERE_USER exported"
        (( _error_count++ ))

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point: ${_name}, VSPHERE_USER export"
        (( _error_count++ ))

      fi

      export VSPHERE_PASSWORD=$(  ${cmd_echo} ${_json}  | ${cmd_jq} -r '.[0].password'  )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, VSPHERE_PASSWORD exported"
        (( _error_count++ ))

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point: ${_name}, VSPHERE_PASSWORD export"
        (( _error_count++ ))

      fi

      export VSPHERE_SERVER=$(    ${cmd_echo} ${_json}  | ${cmd_jq} -r '.[0].server'    )
      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] End Point: ${_name}, VSPHERE_SERVER exported"
        (( _error_count++ ))

      else
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] End Point: ${_name}, VSPHERE_SERVER export"
        (( _error_count++ ))

      fi


    else
      shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] syntax"
      (( _error_count++ ))

    fi

  else
      shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] MOVE_PROFILE not set"

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}