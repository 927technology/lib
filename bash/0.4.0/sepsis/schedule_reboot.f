sepsis.schedule_reboot() {
  # description

  # argument variables
  local _days=30
  local _json_config=
  local _start=
  local _stop=
  local _sttl=
  local _Sttl=

  # local variables
  local _datetime_now=$( date.datetime )
  local _datetime_start=
  local _day_of_week_now=$( date.day_of_week )
  local _day_of_week_start=
  local _epoch_end=
  local _epoch_now=$( date.epoch )
  local _epoch_offset_start=
  local _epoch_start=
  local _executes_count=0
  local _json=
  local _json_hbase=$( hbase.shell.intel )
  local _queues_count=0
  local _uptime=$( utime )

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=
  
  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -d  | --days )
        shift
        _days="${1}"
      ;;
      -f  | --fqdn )
        shift
        _fqdn="${1}"
      ;;
      -j  | --json )
        shift
        _json_config="${1}"
      ;;
      -s  | --start )
        shift
        _start="${1}"
      ;;
      -S  | --stop )
        shift
        _stop="${1}"
      ;;
      -st  | --sttl )
        shift
        _sttl=${1}
      ;;
      -St  | --Sttl )
        shift
        _Sttl=${1}
      ;;
    esac
    shift
  done

  # main
  # get the scheduled start time for the group
  _datetime_start=$( ${cmd_echo} $( date.month )/$( date.day )/$( date.year ) ${_start}:00 )
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - datetime start: ${_datetime_start}
  
  # get the day of the week for the group 0 - 6
  _day_of_week_start=$( ${cmd_echo} ${_json_config} | ${cmd_jq} '.group.day_of_week.number' )
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - day of week start: ${_day_of_week_start}


  _epoch_start=$( ${cmd_echo} ${_datetime_start} | to_epoch )
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - epoch start: ${_epoch_start}
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - datetime start: $( ${cmd_echo} ${_epoch_start} | from_epoch )

  _epoch_end=$( ${cmd_echo} $(( ${_epoch_start} + ${_stop} * 3600 )) )
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - epoch_end: ${_epoch_end}
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - datetime end: $( ${cmd_echo} ${_epoch_end} | from_epoch )

  _epoch_offset_start=$( ${cmd_echo} "${_json_config}"  | ${cmd_jq} -c  'if( .group.hosts | index( "'${_fqdn}'" ) != null ) then  .group.hosts | index( "'${_fqdn}'" ) * '${_sttl}' * 60 + '${_epoch_start}' else 100000000000 end' )
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - epoch offset start: ${_epoch_offset_start}
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - datetime offset start: $( ${cmd_echo} ${_epoch_offset_start} | from_epoch )

  _epoch_offset_stop=$( ${cmd_echo} "${_json_config}"  | ${cmd_jq} -c  'if( .group.hosts | index( "'${_fqdn}'" ) != null ) then .group.hosts | index( "'${_fqdn}'" ) * '${_sttl}' * 60 + '${_Sttl}' * 60 + '${_epoch_start}' else 0 end' )
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - epoch offset stop: ${_epoch_offset_stop}
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - datetime offset stop: $( ${cmd_echo} ${_epoch_offset_stop} | from_epoch )

  # add hbase intel to json
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - gathering hbase intel
  _json=$( json.set --json ${_json}   --key .intel.hbase --value "${_json_hbase}"                             )
  
  # queues checks

  # fqdn is in group.hosts[]
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].name   --value fqdn                     ) 
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].check  --value ${true}                  )
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].pass   --value $( ${cmd_echo} "${_json_config}" | ${cmd_jq} -c '[ .group.hosts[] | select( . | contains("'${_fqdn}'")) ] | length | if( . == 1 ) then '${true}' else '${false}' end' ) )
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].value  --value $( ${cmd_echo} "${_json_config}" | ${cmd_jq} -c '[ .group.hosts[] | select( . | contains("'${_fqdn}'")) ] | length | if( . == 1 ) then '${true}' else '${false}' end' ) )
  # increment check count
  (( _queues_count++ ))


  # set uptime in json
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].name   --value uptime                   ) 
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].check  --value ${_days}                 )
  if [[ ${_days} -le $( utime ) ]]; then
    _json=$( json.set --json ${_json} --key .queues[${_queues_count}].pass   --value ${true}                  )
  else
    _json=$( json.set --json ${_json} --key .queues[${_queues_count}].pass   --value ${false}                 )
  fi
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].value  --value ${_uptime}               )

  # increment check count
  (( _queues_count++ ))


  # set day of week in json
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].name   --value day_of_week              ) 
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].check  --value ${_day_of_week_start}    )
  if [[ ${_day_of_week_now} -eq ${_day_of_week_start} ]]; then
    _json=$( json.set --json ${_json} --key .queues[${_queues_count}].pass   --value ${true}                  )
  else
    _json=$( json.set --json ${_json} --key .queues[${_queues_count}].pass   --value ${false}                 )
  fi
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].value  --value ${_day_of_week_now}      )

  # increment check count
  (( _queues_count++ ))


 # set time of day end is in the future in json
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].name   --value time_of_day_end          ) 
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].check  --value ${_epoch_end}            )
  if  [[ ${_epoch_now} -le ${_epoch_end} ]]; then
    _json=$( json.set --json ${_json} --key .queues[${_queues_count}].pass   --value ${true}                  )
  else
    _json=$( json.set --json ${_json} --key .queues[${_queues_count}].pass   --value ${false}                 )
  fi
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].value  --value ${_epoch_now}            )

  # increment check count
  (( _queues_count++ ))


  # set time offset stop in json
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].name   --value time_offset_stop         ) 
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].check  --value "${_epoch_offset_stop}" )
  if  [[  ${_epoch_now} -le ${_epoch_offset_stop} ]]; then
    _json=$( json.set --json ${_json} --key .queues[${_queues_count}].pass   --value ${true}                  )
  else
    _json=$( json.set --json ${_json} --key .queues[${_queues_count}].pass   --value ${false}                )
  fi
  _json=$( json.set --json ${_json}   --key .queues[${_queues_count}].value  --value ${_epoch_now}            )

  # increment check count
  (( _queues_count++ ))


  # executes checks

  # set time of day start in json
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].name   --value time_of_day_start    ) 
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].check  --value ${_epoch_start}      )
  if  [[ ${_epoch_now} -ge ${_epoch_start} ]]; then
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${true}              )
  else
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${false}             )
  fi
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].value  --value ${_epoch_now}        )

  # increment check count
  (( _executes_count++ ))


  # set time of day end in json
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].name   --value time_of_day_end      ) 
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].check  --value ${_epoch_end}        )
  if  [[  ${_epoch_now} -le ${_epoch_end} ]]; then
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${true}              )
  else
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${false}             )
  fi
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].value  --value ${_epoch_now}        )

  # increment check count
  (( _executes_count++ ))


  # set time offset start in json
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].name   --value time_offset_start    ) 
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].check  --value "${_epoch_offset_start}" )
  if  [[  ${_epoch_now} -ge ${_epoch_offset_start} ]]; then
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${true}              )
  else
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${false}             )
  fi
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].value  --value ${_epoch_now}        )

  # increment check count
  (( _executes_count++ ))



  # intel hbase is master
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].name   --value hbase_master         ) 
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].check  --value ${false}             )
  if  [[  $( ${cmd_echo} ${_json_hbase} | ${cmd_jq} -r '.hostname' ) == $( ${cmd_echo} ${_json_hbase} | ${cmd_jq} -r '.master' ) ]]; then
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${false}             )
    _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].value  --value ${true}            )
    _json=$( json.set --json ${_json}   --key .intel.hbase.is.master  --value ${true}                         )
  else
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${true}              )
    _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].value  --value ${false}           )
    _json=$( json.set --json ${_json}   --key .intel.hbase.is.master  --value ${false}                        )
  fi

  # increment check count
  (( _executes_count++ ))


  # intel hbase is metaserver
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].name   --value hbase_metaserver     ) 
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].check  --value ${false}             )
  if  [[  $( ${cmd_echo} ${_json_hbase} | ${cmd_jq} -r '.hostname' ) == $( ${cmd_echo} ${_json_hbase} | ${cmd_jq} -r '.metaserver' ) ]] && \
      [[ ${METASERVER_REBOOT} == ${false} ]]; then
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${false}             )
    _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].value  --value ${true}            )
    _json=$( json.set --json ${_json}   --key .intel.hbase.is.metaserver  --value ${true}                     )
  else
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${true}              )
    _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].value  --value ${false}           )
    _json=$( json.set --json ${_json}   --key .intel.hbase.is.metaserver  --value ${false}                    )
  fi

  # increment check count
  (( _executes_count++ ))


  # intel hbase is dead - uncomment when going to testing, blocking execute validations 
  # _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].name   --value hbase_dead           ) 
  # _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].check  --value ${true}              )
  # if  [[ $( ${cmd_echo} "${_json_hbase}"  | ${cmd_jq} -c  'if( .dead_servers | index( "'${_fqdn}'" ) != null ) then '${true}' else '${false}' end' ) == ${true} ]]; then
  #   _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${true}              )
  #   _json=$( json.set --json ${_json} --key .executes[${_executes_count}].value  --value ${true}              )
  #   _json=$( json.set --json ${_json} --key .intel.hbase.is.dead  --value ${true}                             )
  # else
  #   _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${false}             )
  #   _json=$( json.set --json ${_json} --key .executes[${_executes_count}].value  --value ${false}             )
  #   _json=$( json.set --json ${_json} --key .intel.hbase.is.dead  --value ${false}                            )
  # fi

  # # increment check count
  # (( _executes_count++ ))


  # intel hbase dead server count
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].name   --value hbase_dead_count     ) 
  _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].check  --value ${DEAD_SERVERS}      )
  if  [[  $( ${cmd_echo} ${_json_hbase} | ${cmd_jq} '.dead_servers | length' ) -lt ${DEAD_SERVERS} ]]; then
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${true}              )
    _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].value  --value ${true}            )
  else
    _json=$( json.set --json ${_json} --key .executes[${_executes_count}].pass   --value ${false}             )
    _json=$( json.set --json ${_json}   --key .executes[${_executes_count}].value  --value ${true}            )
  fi

  # increment check count
  (( _executes_count++ ))


  # set runtime in json
  _json=$( json.set --json ${_json} --key .time.completed     --value $( date.epoch ) || (( _error_count++ )) )


  _exit_string="${_json}"
  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}