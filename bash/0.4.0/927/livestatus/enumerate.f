927.livestatus.enumerate () {
  # description
  # creates ops hosts stanzas based on json configuration provided
  # accepts 2 arguments -
  ## -j/--json json snippit at the root of the commands list
  ## -p/--path which is the full path to the associated conf.d write path

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f


  # argument variables
  local _host=
  local _resource=
  local _service=


  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # variables
  local _json="{}"
  local _json_header="{}"
  local _json_livestatus=
  local _exit_resource=


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
      -s | --service )
        shift
        _service=${1}
      ;;
    esac
    shift
  done


  # main
  if [[ ! -z ${_host}     ]]               && \
     [[ ! -z ${_service}  ]]               && \
     [[ ! -z ${_resource} ]]; then

    case ${_resource} in
      compartment | compartments )
        _exit_cloud=oci
        _exit_resource=compartments
      ;;
      drg | drgs )
        _exit_cloud=oci
        _exit_resource=drgs
      ;;
    esac

    _json_livestatus=$( ${cmd_printf} "GET services\nColumns: plugin_output\nFilter: display_name = ${_service}\nFilter: host_name = ${_host}\n" | ${cmd_unixcat} /var/cache/naemon/live | ${cmd_jq} -c )
    [[ ${?} == ${exit_ok} ]] || (( _error_count++ ))


    _json_configuration=$( ${cmd_echo} ${_json_livestatus} | ${cmd_jq} -c 'try.configuration.'${_exit_resource} )

    #[[ -z ${_json_configuration} == null ]] && _json_configuration="[]"

    _json_status=$( ${cmd_echo} ${_json_livestatus} | ${cmd_jq} -c '.status' )
    #[[ ${?} == ${exit_ok} ]] || (( _error_count++ ))

    [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  fi

  # write json
  ## configuration
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} '.configuration   |=.+ '"${_json_configuration}" )
  
  ## status
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} '.status          |=.+ '"${_json_status}" )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} '.status.cloud    |=.+ "'"${_exit_cloud}"'"' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} '.status.type     |=.+ "'"${_exit_resource}"'"' )

  # output
  _exit_string=${_json}

  ${cmd_echo} ${_exit_string} | ${cmd_jq} -c
  return ${_exit_code}

}
