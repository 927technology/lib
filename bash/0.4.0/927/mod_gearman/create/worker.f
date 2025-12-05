927.mod_gearman.create.worker () {
  # description
  # creates ops templates stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path the full path to the associated conf.d write path
  ## -t/--template if this will be a template or a configuraton.  sets the register option.

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # argument variables
  #none
  
  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # variables
  local _json="{}"
  local _path_gearmand=/etc/mod_gearman
  local _path_naemon=/etc/naemon
  local _path_927=/etc/927


  # worker variables
  local _debug=
  local _dupserver=
  local _dup_results_are_passive=
  local _enable_embedded_perl=
  local _encryption=
  local _eventhandler=
  local _fork_on_exec=
  local _gearman_connection_timeout=
  local _hostgroups=
  local _hosts=
  local _idle_timeout=
  local _job_timeout=
  local _key=
  local _keyfile=
  local _load_limit1=
  local _load_limit5=
  local _load_limit15=
  local _logfile=
  local _max_age=
  local _max_jobs=
  local _max_worker=
  local _min_worker=
  local _notifications=
  local _p1_file=
  local _pidfile=
  local _server=
  local _restrict_command_characters=
  local _restrict_path=
  local _services=
  local _servicegroups=
  local _show_error_output=
  local _spawn_rate=
  local _timeout_return=
  local _use_embedded_perl_implicitly=
  local _use_perl_cache=
  local _workaround_rc_25=


  # parse command arguments
  # none

  ## main
  # read candidate configuration
  _json=$( ${cmd_cat} ${_path_927}${_path_naemon}/candidate/configuration.json | ${cmd_jq} -c '[ .jobworker[] | select(( .enable == true ) and .ops[0].id == "'${WORKER_ID}'") ]' )
  
  if [[ ! -z "${_json}" ]] && [[ $( ${cmd_echo} "${_json}" | ${cmd_jq} '.[] | length' ) > 0 ]]; then

    for workerserver in $(                ${cmd_echo} "${_json}"    | ${cmd_jq} -c '.[]' ); do
      _debug=$(                           ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].debug )                         | if( . == true ) then 0 else 1 end' )

      _dupserver_host=$(                  ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].dupserver.host )                | if( . == null ) then "" else . end' )
      _dupserver_port=$(                  ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].dupserver.port )                | if( . == null ) then 4370 else . end' )

      _dup_results_are_passive=$(         ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].dup_results_are_passive)        | if( . == true ) then "yes" else "no" end' )

      _enable_embedded_perl=$(            ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].enable_embedded_perl)           | if( . == true ) then "yes" else "no" end' )

      _encryption=$(                      ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].encryption.enable )             | if( . == true ) then "yes" else "no" end' )

      _eventhandler=$(                    ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].eventhandler )                  | if( . == true ) then "yes" else "no" end' )

      _fork_on_exec=$(                    ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].fork_on_exec)                   | if( . == true ) then "yes" else "no" end' )

      _gearman_connection_timeout=$(      ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].timeout.gearman_connection )    | if( . == null ) then "" else ( if( . == true ) then 5000 else . end ) end' )

      _hostgroups=$(                      ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].host.groups )                  | if( . | length > 0 ) then join(", ") else "" end' )

      _hosts=$(                           ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].host.enable )                  | if( . == true ) then "yes" else "false" end' )

      _idle_timeout=$(                    ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].idle.timeout )                  | if( . == null ) then 30 else . end' )
      
      _job_timeout=$(                     ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].job.timeout )                   | if( . == null ) then 60 else . end' )

      # _key=$(                           ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].encryption.key' )

      _keyfile=$(                         ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].encryption.keyfile )            | if( . == null ) then "/etc/mod_gearman/secrets/module.pwd" else . end' )

      _load_limit1=$(                     ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].load_limit."1" )               | if( . == null ) then 0 else . end' )
      _load_limit5=$(                     ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].load_limit."5" )               | if( . == null ) then 0 else . end' )
      _load_limit15=$(                    ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].load_limit."15" )              | if( . == null ) then 0 else . end' )

      _logfile=$(                         ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].log.file )                     | if( . == null ) then "/var/log/mod_gearman/mod_gearman_neb.log" else . end' )

      _max_age=$(                         ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].max.age )                      | if( . == null ) then 0 else . end' )

      _max_jobs=$(                        ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].max.jobs )                     | if( . == null ) then 1000 else . end' )

      _max_worker=$(                      ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].max.worker )                   | if( . == null ) then 50 else . end' )

      _min_worker=$(                      ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].min.worker )                   | if( . == null ) then 5 else . end' )

      _notifications=$(                   ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].notifications )                 | if( . == true ) then "yes" else "no" end' )

      _p1_file=$(                         ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].p1_file )                       | if( . == null ) then "/usr/share/mod_gearman/mod_gearman_p1.pl" else . end' )

      _pidfile=$(                         ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].pidfile )                       | if( . == null ) then "/run/mod_gearman_worker.pid" else . end' )

      _server_host=$(                     ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].server.host )                   | if( . == null ) then "localhost" else . end' )
      _server_port=$(                     ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].server.port )                   | if( . == null ) then 4370 else . end' )

      _restrict_command_characters=$(     ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].restrict_command_characters )   | if( . == null ) then "" else . end' )

      _restrict_path=$(                   ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].restrict_path )                 | if( . == null ) then "/usr/local/plugins/" else . end' )

      _servicegroups=$(                   ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].service.groups )                | if( . | length > 1 ) then "" else join(", ") end' )

      _services=$(                        ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].service.enable )                | if( . == true ) then "yes" else "no" end' )

      _show_error_output=$(               ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].show_error_output )             | if( . == true ) then "yes" else "no" end' )

      _spawn_rate=$(                      ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].spawn_rate )                    | if( . == null ) then 1 else . end' )
      
      _timeout_return=$(                  ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].timeout.return )                | if( . == null ) then 2 else . end' )

      _use_embedded_perl_implicitly=$(    ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].use_embedded_perl_implicitly )  | if( . == true ) then "on" else "off" end' )
      
      _use_perl_cache=$(                  ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].use_perl_cache )                | if( . == true ) then "on" else "off" end' )
      
      _workaround_rc_25=$(                ${cmd_echo} "${workerserver}"   | ${cmd_jq} -r  'try( .ops[0].workaround_rc_25 )              | if( . == true ) then "on" else "off" end' )

      # write file
      if shell.create.file --group root --owner naemon --path ${_path_gearmand}/worker.conf; then

        shell.log --screen --message "WRITING: ${_path_gearmand}/worker.conf"
        ${cmd_cat} << EOF.worker > ${_path_gearmand}/worker.conf
debug=${_debug}
$( [[ ! -z ${_dupserver_host} ]]                          &&  ${cmd_echo} dupserver=${_dupserver_host}:${_dupserver_port} )
dup_results_are_passive=${_dup_results_are_passive}

enable_embedded_perl=${_enable_embedded_perl}

encryption=${_encryption}

eventhandler=${_eventhandler}

fork_on_exec=${_fork_on_exec}

gearman_connection_timeout=${_gearman_connection_timeout}

hostgroups=${_hostgroups}

hosts=${_hosts}

idle-timeout=${_idle_timeout}

job_timeout=${_job_timeout}

# key=${_keys}

keyfile=${_keyfile}

load_limit1=${_load_limit1}

load_limit5=${_load_limit5}

load_limit15=${_load_limit15}

logfile=${_logfile}

max-age=${_max_age}

max-jobs=${_max_jobs}

max-worker=${_max_worker}

min-worker=${_min_worker}

notifications=${_notifications}

p1_file=${_p1_file}

pidfile=${_pidfile}

restrict_command_characters=${_restrict_command_characters}

restrict_path=${_restrict_path}

server=${_server_host}:${_server_port}

$( [[ ! -z ${_servicegroups} ]]                           &&  ${cmd_echo} servicegroups=${_servicegroups} )

services=${_services}

show_error_output=${_show_error_output}

spawn-rate=${_spawn_rate}

timeout_return=${_timeout_return}

use_embedded_perl_implicitly=${_use_embedded_perl_implicitly}

use_perl_cache=${_use_perl_cache}

workaround_rc_25=${_workaround_rc_25}
EOF.worker
      
        ${cmd_sed} -i '/^[[:space:]]*$/d' ${_path_gearmand}/worker.conf
      
      else
        (( _error_count++ ))
      fi
      
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