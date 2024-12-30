zabbix.get.hostid () {
  # description
  

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f


  # argument variables
  local _host=
  local _token=
  local _url=api_jsonrpc.php
  local _resource=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # variables
  local _header="Content-Type: application/json-rpc"
  local _json="{}"
  local _json_rpc=2.0
  local _json_method=host.get
  local _json_id=1  


  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -h | --host )
        shift
        _host=${1}
      ;;
      -r | --resource )
        shift
        _resource=${1}
      ;;
      -t | --token )
        shift
        _token=${1}
      ;;
    esac
    shift
  done

  # main
  ## build json
    ## build json
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.jsonrpc             |=.+ "'"${_json_rpc}"'"' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.method              |=.+ "'"${_json_method}"'"' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.params.output       |=.+ ["hostid","host"]' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.id                  |=.+ "'"${_json_id}"'"' )




  _json=$( ${cmd_curl} -s --request POST --url http://${_host}/${_url} --header 'Content-Type: application/json-rpc' --header 'Authorization: Bearer '${_token} --data ${_json} | ${cmd_jq} '.result' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # output
  _exit_string=${_json}

  ${cmd_echo} ${_exit_string} | ${cmd_jq} -c
  return ${_exit_code}

}