zabbix.bearertoken () {

  # description
  

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f


  # argument variables
  local _host=
  local _password=
  local _user=
  local _url=api_jsonrpc.php


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # variables
  local _header="Content-Type: application/json-rpc"
  local _json="{}"
  local _json_rpc=2.0
  local _json_method=user.login
  local _json_id=1  
  local _token=


  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -h | --host )
        shift
        _host=${1}
      ;;
      -p | --password )
        shift
        _password=${1}
      ;;
      -u | --user )
        shift
        _user=${1}
      ;;
    esac
    shift
  done


  # main
  ## build json
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.jsonrpc             |=.+ "'"${_json_rpc}"'"' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.method              |=.+ "'"${_json_method}"'"' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.params.username     |=.+ "'"${_user}"'"' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.params.password     |=.+ "'"${_password}"'"' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.id                  |=.+ "'"${_json_id}"'"' )

 

  _token=$( ${cmd_curl} -s --request POST --url http://${_host}/${_url} --header 'Content-Type: application/json-rpc' --data ${_json} | ${cmd_jq} -r '.result' ) 
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # output
  _exit_string=${_token}

  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}