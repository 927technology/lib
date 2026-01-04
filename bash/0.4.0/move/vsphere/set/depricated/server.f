move.vsphere.set.server() {
  # global variables
  declare -g VSPHERE_USER=
  declare -g VSPHERE_PASSWORD=
  declare -g VSPHERE_USER=

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
  if  [[ ! -z ${_name} ]] && \
      [[ $( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '[ .vsphere[] | select(.name == "'${_name}'") ] | length' ) > 0 ]]; then

    # unset existing env_vars
    for env_var in $( set | ${cmd_awk} '{FS="="} /^VSPHERE_/ {print $1}' ); do 
      unset ${env_var}
    done

    # set credentials
    export VSPHERE_NAME=${_name}
    export VSPHERE_USER=$( ${cmd_cat} /usr/local/etc/move/connect.json      | ${cmd_jq} -r '.vsphere[] | select(.name == "'${_name}'").user' )
    export VSPHERE_PASSWORD=$( ${cmd_cat} /usr/local/etc/move/connect.json  | ${cmd_jq} -r '.vsphere[] | select(.name == "'${_name}'").password' )
    export VSPHERE_SERVER=$( ${cmd_cat} /usr/local/etc/move/connect.json    | ${cmd_jq} -r '.vsphere[] | select(.name == "'${_name}'").server' )

    _exit_code=${exit_ok}

  else
    _exit_code=${exit_crit}

  fi

  # exit
  return ${_exit_code}
}




move.vsphere.set.server() {
  # local variables
  # none

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
  if  [[ ! -z ${_name} ]] && \
      [[ $( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '[ .vsphere[] | select(.name == "'${_name}'") ] | length' ) > 0 ]]; then

    # unset existing env_vars
    for env_var in $( set | ${cmd_awk} '{FS="="} /^VSPHERE_/ {print $1}' ); do 
      unset ${env_var}
    done

    # set credentials
    if  [[ $( ${cmd_cat} /usr/local/etc/move/connect.json  | ${cmd_jq} -c '[ .vsphere[] | select(.name == "'${_name}'") ] | length' ) > 0 ]]; then
      export VSPHERE_NAME=${_name}
      export VSPHERE_USER=$( ${cmd_cat} /usr/local/etc/move/connect.json      | ${cmd_jq} -r '.vsphere[] | select(.name == "'${_name}'").user' )
      export VSPHERE_PASSWORD=$( ${cmd_cat} /usr/local/etc/move/connect.json  | ${cmd_jq} -r '.vsphere[] | select(.name == "'${_name}'").password' )
      export VSPHERE_SERVER=$( ${cmd_cat} /usr/local/etc/move/connect.json    | ${cmd_jq} -r '.vsphere[] | select(.name == "'${_name}'").server' )

    fi
  fi

  # exit
  return ${_exit_code}
}