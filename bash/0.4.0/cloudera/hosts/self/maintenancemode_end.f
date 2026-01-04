cloudera.hosts.self.maintenancemode_end() {
  # description

  # variables
  local _api_version=v19
  local _maintenancemode_requested=${false}
  local _count=0
  local _json=
  local _json_host_self=$( cloudera.hosts.self )
  local _sleep=${SLEEP}
  local _state=$( cloudera.hosts.self.is_maintenancemode )
  local _timeout=15 #minutes
  local _time_start=$( date.epoch )

  # control variables
  local _exit_code=${exit_crit}
  local _exit_string=

  # argument variables
  # none

  # parse arguments
  # none

  # main
  # get maintenanceMode
  _json=$( json.set --json "${_json}" --key .state.is_maintenancemode --value ${_state} )
  

  # while state is false and time has not exceeded timeout threshold
  while [[ ${_state} == ${true}                                                ]]  &&  \
        [[ $(( $( date.epoch ) - ${_time_start} )) -le $(( ${_timeout} * 60 ))  ]]; do 

    # output timeout seconds left
    [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - retry seconds remaining: $(( ( $( date.epoch ) - ${_time_start} - ${_timeout} * 60 ) * -1 ))

    # get self info from cloudera
    _json_host_self=$( cloudera.hosts.self )

    # reset loop variables
    _state=${false}

    # update current state in array
    _state=$( cloudera.hosts.self.is_maintenancemode )
    [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - maintenance mode: $( [[ ${_state} == ${true} ]] && ${cmd_echo} true || ${cmd_echo} false )

    # set attempt status in json
    _json=$( json.set --json "${_json}" --key .state.attempt[${_count}].date            --value $( date.epoch ) )
    _json=$( json.set --json "${_json}" --key .state.attempt[${_count}].maintenancemode  --value ${_state} )

    # set status
    if  [[ ${_state} == ${true} ]] &&   \
        [[ ${_maintenancemode_requested} == ${false} ]]; then

      # exit maintenance mode
      _json=$( json.set --json "${_json}" --key .maintenancemode.data --value "$( cloudera.api --api /hosts/$( ${cmd_hostname} -f )/commands/exitMaintenanceMode ${@} )" )
      _maintenancemode_requested=${true}
      [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - end maintenance mode: requested
    
    elif [[ ${_state} == ${true} ]]; then
      _json=$( json.set --json "${_json}" --key .state.is_maintenancemode --value ${true} )
      _json=$( json.set --json "${_json}" --key .state.date --value $( date.epoch ) )

      [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - end maintenance mode: successful

      _exit_code=${exit_ok}
    
    fi

    (( _count++ ))
    [[ ${_state} == ${false} ]] && ${cmd_sleep} $(( ${_sleep} * 60 ))

  done

  _exit_string=$( ${cmd_echo} "${_json}" | ${cmd_jq} -c )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}