cloudera.api() {
  # description

  # variables
  # local _api_version=v6
  local _api_version=v19
  local _request=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _api=
  local _auth_file=${ROOT_PATH}/etc/sepsis/auth.pwd
  local _json=
  local _json_api="{}"
  local _url=${CLOUDERA_URL}

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in 
      -a | --api )
        shift
        _api=${1}
      ;;
      -f | --file-authentication )
        shift
        _auth_file="${1}"
      ;;
      -u | --url )
        shift
        _url="${1}"
      ;;
    esac
    shift
  done

  # main
  _json_api=$( json.set --json ${_json_api} --key ".items[0]" --value "$( hostname -f )" )


  case ${_api} in
    /cm/commands/hostsDecommission          | \
    /cm/commands/hostsRecommission          | \
    /cm/commands/hostsRecommissionWithStart | \
    /hosts/*/commands/exitMaintenanceMode   )
      _request=POST
    ;;
  esac

  # curl the api
  case ${_request} in
    POST )
      _json=$(                                      \
        ${cmd_curl}                                 \
        -k                                          \
        -s                                          \
        -u $( ${cmd_cat} ${_auth_file} )            \
        --header "Content-Type: application/json"   \
        --request POST                              \
        --data ${_json_api}                         \
        ${_url}/api/${_api_version}${_api}          \
        | ${cmd_jq} -c                              \
      )
    ;;
    * )
      _json=$( ${cmd_curl} -s -k -u $( ${cmd_cat} ${_auth_file} ) ${_url}/api/${_api_version}${_api} | ${cmd_jq} -c )
    ;;
  esac

  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}


  _exit_string=${_json}
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}