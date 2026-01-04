move.get_coriolisserver_credentials() {
  # local variables
  declare -g _user=
  declare -g _password=
  declare -g _viserver=

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
  if [[ ! -z ${_name} ]]; then
    # get credentials
    export OS_AUTH_URL=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").server' )
    export OS_PASSWORD=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").password' )
    export OS_TENANT_NAME=${_name}
    export OS_USERNAME=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").user' )
    export OS_PROJECT_ID=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '.coriolis[] | select(.name == "'${_name}'").project_id' )
  
  fi

  # exit
  return ${_exit_code}
}