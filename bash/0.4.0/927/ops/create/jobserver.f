927.ops.create.jobserver () {
  # description
  # creates ops templates stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f


  # argument variables
  local _json=
  local _path=
  local _template=${false}


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # worker variables
  local _accept_clear_results=
  local _debug=
  local _do_hostchecks=
  local _dupserver_host=
  local _dupserver_port=
  local _encryption=
  local _eventhandler=
  local _gearman_connection_timeout=
  local _hostgroups=
  local _hosts=
  local _internal_check_dummy=
  local _latency_flatten_window=
  local _localhostgroups=
  local _localservicegroups=
  local _logfile=
  local _log_stats_interval=
  local _key=
  local _keyfile=
  local _notifications=
  local _orphan_host_checks=
  local _orphan_return=
  local _orphan_service_checks=
  local _perfdata=
  local _perfdata_mode=
  local _perfdata_send_all=
  local _queue_custom_variable=
  local _result_workers=
  local _route_eventhandler_like_checks=
  local _server_host=
  local _server_port=
  local _servicegroups=
  local _services=
  local _use_uniq_jobs=


  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -j | --json )
        shift
        _json="${1}"
      ;;
      -p | --path )
        shift
        _path=${1}
      ;;
    esac
    shift
  done


  ## main
  echo $_path
  ${cmd_echo} 10
  echo ${_json} | jq '. | length'
  echo $SERVER_ID
  echo 12
  echo $_json | jq '.[0].enable'
  echo $_json | jq '.[0].ops[0].id'
  echo 13
  if [[ ! -z "${_json}" ]] && [[ $( ${cmd_echo} "${_json}" | ${cmd_jq} '.[] | length' ) > 0 ]]; then
    # [[ ! -d ${_path} ]] && ${cmd_mkdir} -p ${_path} || ${cmd_rm} -rf ${_path}/*

    for jobserver in $(                   ${cmd_echo} "${_json}"        | ${cmd_jq} -c '.[] | select(( .enable == true ) and .ops[0].id == "'${SERVER_ID}'")' ); do 
      _accept_clear_results=$(            ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].accept_clear_result )           | if( . == '${true}' ) then "yes" else "no" end' )
      
      _debug=$(                           ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].debug )                         | if( . == '${true}' ) then 0 else 1 end' )
  
      _do_hostchecks=$(                   ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].do_hostchecks )                 | if( . == null ) then "" else ( if( . == true ) then "yes" else "no" end ) end' )
  
      _dupserver_host=$(                  ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].dupserver.host )                | if( . == null ) then "" else . end' )
      _dupserver_port=$(                  ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].dupserver.port )                | if( . == null ) then 4370 else . end' )
      
      _encryption=$(                      ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].encryption.enable )             | if( . == '${true}' ) then "yes" else "no" end' )
      
      _eventhandler=$(                    ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].eventhandler )                  | if( . == '${true}' ) then "yes" else "no" end' )
      
      _gearman_connection_timeout=$(      ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].connection_timeout )            | if( . == null ) then "" else ( if( . == true ) then "yes" else "no" end ) end' )
      
      _hostgroups=$(                      ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].host.groups[] )                 | if( . | length > 1 ) then "" else join(", ") end' )
      
      _hosts=$(                           ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].hosts.enable )                  | if( . == '${true}' ) then "yes" else "no" end' )
      
      _internal_check_dummy=$(            ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].internal_check_dummy )          | if( . == '${true}' ) then "yes" else "no" end' )
      
      _latency_flatten_window=$(          ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].latency_flatten_window )        | if( . == null ) then 30 else . end' )
      
      _localhostgroups=$(                 ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].host.local_groups )             | if( . | length > 1 ) then "" else join(", ") end' )
      
      _localservicegroups=$(              ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].service.local_groups )          | if( . | length > 1 ) then "" else join(", ") end' )
      
      _logfile=$(                         ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].log.file )                      | if( . == null ) then "/var/log/mod_gearman/mod_gearman_neb.log" else . end' )
      
      _log_stats_interval=$(              ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].log.stats_interval )            | if( . == null ) then "" else . end' )
      
      # _key=$(                             ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].encryption.key' ) 
        
      _keyfile=$(                         ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].encryption.keyfile )            | if( . == null ) then "secrets/module.pwd" else . end' )
      
      _notifications=$(                   ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].notifications )                 | if( . == '${true}' ) then "yes" else "no" end' )
      
      _orphan_host_checks=$(              ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].host.orphan_checks )            | if( . == '${true}' ) then "yes" else "no" end' )
      
      _orphan_return=$(                   ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].orphan_return )                 | if( . == null ) then 2 else . end' )
      
      _orphan_service_checks=$(           ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].service.orphan_checks )         | if( . == '${true}' ) then "yes" else "no" end' )
      
      _perfdata=$(                        ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].perfdata.enable )               | if( . == '${true}' ) then "yes" else "no" end' )
      
      _perfdata_mode=$(                   ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].perfdata.mode )                 | if( . == null ) then 1 else . end' )
      
      _perfdata_send_all=$(               ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].perfdata.send_all )             | if( . == '${true}' ) then "yes" else "no" end' )
      
      _queue_custom_variable=$(           ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].queue_custom_variable )         | if( . == "worker" ) then "WORKER" else "SERVER" end' )
      
      _result_workers=$(                  ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].result_workers )                | if( . == null ) then 1 else . end' )
      
      _route_eventhandler_like_checks=$(  ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].route_eventhandler_like_checks )| if( . == '${true}' ) then "yes" else "no" end' )
      
      _server_host=$(                     ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].server.host )                   | if( . == null ) then "localhost" else . end' )
      _server_port=$(                     ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].server.port )                   | if( . == null ) then 4370 else . end' )
      
      _servicegroups=$(                   ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].service.groups )                | if( . | length > 1 ) then "" else join(", ") end' )
      
      _services=$(                        ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].service.enable )                | if( . == '${true}' ) then "yes" else "no" end' )
      
      _use_uniq_jobs=$(                   ${cmd_echo} "${jobserver}"    | ${cmd_jq} -r  'try( .ops[0].use_uniq_jobs )                 | if( . == '${true}' ) then "on" else "off" end' )


      # write file
      shell.log --screen --message "Writing Job Server/Worker: ${_path}/module.conf"
      ${cmd_cat} << EOF.config > ${_path}/module.conf
accept_clear_results=${_accept_clear_results}
debug=${_debug}
do_hostchecks=${_do_hostchecks}
$( [[ ! -z ${_dupserver_host} ]]                          &&  ${cmd_echo} dupserver=${_dupserver_host}:${_dupserver_port} )
encryption=${_encryption}
eventhandler=${_eventhandler}
$( [[ ! -z ${_gearman_connection_timeout} ]]              &&  ${cmd_echo} gearman_connection_timeout=${_gearman_connection_timeout} )
$( [[ ! -z ${_hostgroups} ]]                              &&  ${cmd_echo} hostgroups=${_hostgroups} )
hosts=${_hosts}

internal_check_dummy=${_internal_check_dummy}

latency_flatten_window=${_latency_flatten_window}

localhostgroups=${_localhostgroups}

localservicegroups=${_localservicegroups}

logfile=${_logfile}

$( [[ ! -z ${_log_stats_interval} ]]                      &&  ${cmd_echo} log_stats_interval=${_log_stats_interval} )

keyfile=${_keyfile}

notificaitons=${_notifications}

orphan_host_checks=${_orphan_host_checks}

orphan_return=${_orphan_return}

orphan_service_checks=${_orphan_service_checks}

perfdata=${_perfdata}

perfdata_mode=${_perfdata_mode}

perfdata_send_all=${_perfdata_send_all}

queue_custom_variable=${_queue_custom_variable}

result_workers=${_result_workers}

route_eventhandler_like_checks=${_route_eventhandler_like_checks}

server=${_server_host}:${_server_port}

$( [[ ! -z ${_servicegroups} ]]                           &&  ${cmd_echo} servicegroups=${_servicegroups} )

services=${_services}

use_uniq_jobs=${_use_uniq_jobs}
EOF.config

      [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
      ${cmd_sed} -i '/^[[:space:]]*$/d' ${_path}/module.conf
    done 

    if [[ ${_error_count} > 0 ]]; then
      _exit_code=${exit_crit}
      _exit_strin=${false}

    else  
      _exit_code=${exit_ok}
      _exit_strin=${true}

    fi

    # exit
    ${cmd_echo} ${_exit_string}
    return ${_exit_code}

  fi
}