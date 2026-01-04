cloudera.hosts.self.decommission() {
  # description

  # variables
  local _api_version=v19
  local _count=0
  local _json=
  local _json_host_self=$( cloudera.hosts.self )
  local _sleep=${SLEEP}
  local -A _state=
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
  # get commissionState
  _json=$( json.set --json ${_json} --key .state.is_decommissioned --value ${false} )
  

  # while state is false and time has not exceeded timeout threshold
  while ( 
      [[ ${_state[decommissioned]} == ${false} ]]   ||  \
      [[ -z ${_state[decommissioned]} ]]                \
    )                                               &&  \
    [[ $(( $( date.epoch ) - ${_time_start} )) -le $(( ${_timeout} * 60 )) ]]; do 

    # output timeout seconds left
    [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - retry seconds remaining: $(( ( $( date.epoch ) - ${_time_start} - ${_timeout} * 60 ) * -1 ))



    # get self info from cloudera
    _json_host_self=$( cloudera.hosts.self )

    # reset loop variables
    _state[commissioned]=${false}
    _state[decommissioned]=${false}
    _state[decommissioning]=${false}

    # update current state in array
    _state[$( ${cmd_echo} ${_json_host_self} | ${cmd_jq} -r '.commissionState | . |= ascii_downcase' )]=${true}
    [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - commissioned: $( [[ ${_state[commissioned]} == ${true} ]] && ${cmd_echo} true || ${cmd_echo} false )
    [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - decommissioning: $( [[ ${_state[decommissioning]} == ${true} ]] && ${cmd_echo} true || ${cmd_echo} false )
    [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - decommissioned: $( [[ ${_state[decommissioned]} == ${true} ]] && ${cmd_echo} true || ${cmd_echo} false )

    # set attempt status in json
    _json=$( json.set --json ${_json} --key .state.attempt[${_count}].date            --value $( date.epoch ) )
    _json=$( json.set --json ${_json} --key .state.attempt[${_count}].commissioned    --value ${_state[commissioned]} )
    _json=$( json.set --json ${_json} --key .state.attempt[${_count}].decommissioned  --value ${_state[decommissioned]} )
    _json=$( json.set --json ${_json} --key .state.attempt[${_count}].decommissioning --value ${_state[decommissioning]} )

    # set status
    if [[ ${_state[commissioned]} == ${true} ]]; then
      _json=$( json.set --json ${_json} --key .decommission.data --value "$( cloudera.api --api /cm/commands/hostsDecommission ${@} )" )
      [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - decommission: requested
    
    elif [[ ${_state[decommissioned]} == ${true} ]]; then
      _json=$( json.set --json ${_json} --key .state.is_decommissioned --value ${true} )
      _json=$( json.set --json ${_json} --key .state.date --value $( date.epoch ) )

      [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - decommission: successful

      _exit_code=${exit_ok}
    
    fi

    (( _count++ ))
    [[ ${_state[decommissioned]} == ${false} ]] && ${cmd_sleep} $(( ${_sleep} * 60 ))
  done


  _exit_string=$( ${cmd_echo} ${_json} | ${cmd_jq} -c )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}