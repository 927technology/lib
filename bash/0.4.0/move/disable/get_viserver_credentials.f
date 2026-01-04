move.get_viserver_credentials() {
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
    export _user=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '.vcenters[] | select(.name == "'${_name}'").user' )
    export _password=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '.vcenters[] | select(.name == "'${_name}'").password' )
    export _viserver=$( ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '.vcenters[] | select(.name == "'${_name}'").server' )
  fi

  # exit
  return ${_exit_code}
}