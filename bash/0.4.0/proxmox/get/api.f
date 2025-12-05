proxmox.get.api() {
  # dependancies

  # local variables
  local _api_key_name=
  local _api_key_value=
  local _api_user=
  local _api_user_realm=
  local _host=
  local _host_port=
  local _json="{}"
  local _node=
  local _path=
  local _path_input=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -akn  | --api-key-name )
        shift
        _api_key_name=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -akv  | --api-key-value )
        shift
        _api_key_value=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -au  | --api-user )
        shift
        _api_user=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -aur  | --api-user-realm )
        shift
        _api_user_realm=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -h  | --host )
        shift
        _host=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -hp  | --host-port )
        shift
        _host_port=$( ${cmd_echo} "${1}" )
      ;;
      -n | --node )
        shift
        _node=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p  | --path )
        shift
        _path_input=$( ${cmd_echo} "${1}" | lcase )
      ;;
    esac
    shift
  done

  # control variables
  # none

  # main
  # validate variables
  ${cmd_echo} "${_api_key_name}"    | is_string   >/dev/null 2>&1 || { ${cmd_echo} "invalid --api-key-name"   >&2; return ${exit_crit}; }
  ${cmd_echo} "${_api_key_value}"   | is_string   >/dev/null 2>&1 || { ${cmd_echo} "invalid --api-key-value"  >&2; return ${exit_crit}; }
  ${cmd_echo} "${_api_user}"        | is_string   >/dev/null 2>&1 || { ${cmd_echo} "invalid --api-user"       >&2; return ${exit_crit}; }
  ${cmd_echo} "${_api_user_realm}"  | is_string   >/dev/null 2>&1 || { ${cmd_echo} "invalid --api-user-realm" >&2; return ${exit_crit}; }
  ${cmd_echo} "${_host}"            | is_string   >/dev/null 2>&1 || { ${cmd_echo} "invalid --host"           >&2; return ${exit_crit}; }
  ${cmd_echo} "${_host_port}"       | is_integer  >/dev/null 2>&1 || { ${cmd_echo} "invalid --host-port"      >&2; return ${exit_crit}; }
  ${cmd_echo} "${_path_input}"      | is_string   >/dev/null 2>&1 || { ${cmd_echo} "invalid --path"           >&2; return ${exit_crit}; }

  # translate input to api
  case $( ${cmd_echo} ${_path_input} | ${cmd_awk} -F"/" '{print $1}' ) in
    cluster )
      case ${_path_input} in
        cluster/firewall/rules  ) _path="cluster/firewall/rules"          ;;
        cluster/jobs            ) _path="cluster/jobs"                    ;;
        cluster/mappings        ) _path="cluster/mapping"                 ;;
        cluster/metrics         ) _path="cluster/metrics"                 ;;
        cluster/nodes           ) _path="cluster/resources?type=node"     ;;
        cluster/resources       ) _path="cluster/resources"               ;;
        cluster/sdns            ) _path="cluster/resources?type=sdn"      ;;
        cluster/status          ) _path="cluster/status"                  ;;
        cluster/storages        ) _path="cluster/resources?type=storage"  ;;
        cluster/vms             ) _path="cluster/resources?type=vm"       ;;
      esac
    ;;
    node )
      if [[ ! -z ${_node} ]]; then
        case ${_path_input} in
          node/apt              ) _path="nodes/${_node}/apt"              ;;
          node/status           ) _path="nodes/${_node}/status"           ;;
          node/syslog           ) _path="nodes/${_node}/syslog"           ;;

        esac
      fi
    ;;
  esac
echo ----------------
echo "https://${_host}:${_host_port}/api2/json/${_path}"
echo ----------------

  # query api
  _json=$(                                                                                                \
    ${cmd_curl}                                                                                           \
      -s                                                                                                  \
      -k                                                                                                  \
      -X GET "https://${_host}:${_host_port}/api2/json/${_path}"                                          \
      -H "Authorization: PVEAPIToken=${_api_user}@${_api_user_realm}!${_api_key_name}=${_api_key_value}"
  )

  # validate json
  ${cmd_echo} "${_json}" | is_json > /dev/null 2>&1 || (( _error_count++ )) 

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  ${cmd_echo} ${_json}
  return ${_exit_code}
}