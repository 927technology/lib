cloudera.hosts.self.validate() {
  # description

  # variables
  local _attempt=0
  local _is_commissioned=${false}
  local _is_healthy=${false}
  local _is_maintenancemode=${true}
  local _json="[]"
  local _json_health="{}"
  local _validate=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _max_attempts=${VALIDATE_MAX_ATTEMPTS}
  local _sleep=${SLEEP}

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -m | --max-attempts )
        shift
        _max_attempts=${1}
      ;;
      -s | --sleep )
        shift
        _sleep=${1}
      ;;
    esac
    shift
  done

  # main
  # get initial status
  _is_commissioned=$( cloudera.hosts.self.is_commissioned )
  _is_healthy=$( cloudera.hosts.self.healthy )
  _is_maintenancemode=$( cloudera.hosts.self.is_maintenancemode )

  # set date in json
  _json=$( json.set --json "${_json}" --key .[${_attempt}].date --value $( date.epoch ) )
  
  # set commission status in json
  _json=$( json.set --json "${_json}" --key .[${_attempt}].cloudera.hosts.self.commissioned --value ${_is_commissioned} )
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - commissioned\($(( ${_attempt} + 1 ))/${_max_attempts}\): "${_is_commissioned}"

  # set maintenancemode status in json
  _json=$( json.set --json "${_json}" --key .[${_attempt}].cloudera.hosts.self.maintenancemode --value ${_is_maintenancemode} )
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - maintenance mode\($(( ${_attempt} + 1 ))/${_max_attempts}\): "${_is_maintenancemode}"

  # set health health status in json
  _json=$( json.set --json "${_json}" --key .[${_attempt}].cloudera.hosts.self.healthy --value ${_is_healthy} )
  [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - healthy\($(( ${_attempt} + 1 ))/${_max_attempts}\): "${_is_healthy}"

  # get role health
  _json_health=$( cloudera.hosts.self | ${cmd_jq} -c  '.healthChecks' )

  # set health health status in json
  _json=$( json.set --json "${_json}" --key .[${_attempt}].cloudera.hosts.self.healthy --value ${_is_healthy} )

  # set role health in json
  _json=$( json.set --json "${_json}" --key .[${_attempt}].cloudera.hosts.self.healthchecks --value "${_json_health}" )

  # attempt 0 never tries to commisson and start roles, but needs to be annotated in the json
  _json=$( json.set --json "${_json}" --key .[${_attempt}].commission.data --value "{}" )
  _json=$( json.set --json "${_json}" --key .[${_attempt}].decommission.data --value "{}" )

  (( _attempt++ ))

  while [[ ${_attempt} < ${VALIDATE_MAX_ATTEMPTS} ]]  &&  \
        ( [[ ${_is_commissioned} == ${false}      ]]  ||  \
          [[ ${_is_healthy} == ${false}           ]]  ||  \
          [[ ${_is_maintenancemode} == ${true}    ]]      \
        ); do 

    # attempt to commission and start roles
    if  [[ ${_is_commissioned} == ${false}  ]] || \
        [[ ${_is_healthy} == ${false}       ]]; then

      # attempt to commission and start roles - this does not always end maintenance mode
      # >&2  cloudera.hosts.self.commission
      cloudera.hosts.self.commission 2> /dev/null
      # _json=$( json.set --json "${_json}" --key .[${_attempt}].commission.data --value $( cloudera.hosts.self.commission ) )

      # attempt to end maintenance mode
      # >&2 cloudera.hosts.self.maintenancemode_end
      _json=$( json.set --json "${_json}" --key .[${_attempt}].maintenancemode.data --value $( cloudera.hosts.self.maintenancemode_end ) )

      # update status
      _is_commissioned=$( cloudera.hosts.self.is_commissioned )
      [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - commissioned\($(( ${_attempt} + 1 ))/${_max_attempts}\): "${_is_commissioned}"

      _is_healthy=$( cloudera.hosts.self.healthy )
      [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - healthy\($(( ${_attempt} + 1 ))/${_max_attempts}\): "${_is_healthy}"

    fi

    # set date in json
    _json=$( json.set --json "${_json}" --key .[${_attempt}].date --value $( date.epoch ) )
    
    # set commission status in json
    _json=$( json.set --json "${_json}" --key .[${_attempt}].cloudera.hosts.self.commissioned --value "${_is_commissioned}" )

    # set health health status in json
    _json=$( json.set --json "${_json}" --key .[${_attempt}].cloudera.hosts.self.healthy --value "${_is_healthy}" )

    # get role health
    _json_health=$( cloudera.hosts.self | ${cmd_jq} -c  '.healthChecks' )
    
    # set role health in json
    _json=$( json.set --json "${_json}" --key .[${_attempt}].cloudera.hosts.self.healthchecks --value "${_json_health}" )

    # output role health
    for check in $( ${cmd_echo} ${_json_health} | ${cmd_jq} -c '.[]' ); do
      [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - name\($(( ${_attempt} + 1 ))/${_max_attempts}\): "$( ${cmd_echo} ${check} | ${cmd_jq} -r '.name' )"
      [[ ${VERBOSE} == ${true} ]] && >&2 ${cmd_echo} $( date.pretty ) - is healthy\($(( ${_attempt} + 1 ))/${_max_attempts}\): "$( ${cmd_echo} ${check} | ${cmd_jq} '. | if( .summary == "GOOD" ) then true else false end' )"
    done   

    (( _attempt++ ))
  done

  # set exit code
  if  [[ ${_is_commissioned} == ${false}  ]] || \
      [[ ${_is_healthy} == ${false}       ]]; then
    _exit_code=${exit_crit}

  else
    _exit_code=${exit_ok}
  
  fi

  _exit_string="${_json}"

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}