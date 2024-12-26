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
  local _json_resource=
  local _output=
  local _resource_name=


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
        _cloud_name=oci
        _resource_name=compartments
      ;;
      drg | drgs )
        _cloud_name=oci
        _resource_name=drgs
      ;;
      iac )
        _cloud_name=internal
        _resource_name=iac
      ;;
      ops )
        _cloud_name=internal
        _resource_name=ops
      ;;
    esac


    _output=$( ${cmd_printf} "GET services\nColumns: plugin_output\nFilter: display_name = ${_service}\nFilter: host_name = ${_host}\n" | ${cmd_unixcat} /var/cache/naemon/live | ${cmd_jq} -c )
    [[ ${?} == ${exit_ok} ]] || (( _error_count++ ))


    case ${_service} in
      iac-config )
        _json_resource=$( ${cmd_echo} "${_output}" | ${cmd_jq} '. | if( try.data[0].iac[0].'${_resource}' ) then .data[0].iac[0].'${_resource}' else [] end' )
        #_json_resource=$( ${cmd_echo} ${_output} | ${cmd_jq} 'if(try.data[0].iac[0].'${_resource}') then .data[0].'${_resource}' else [] end' )
 
      ;;
      * )
        _json_resource=$( ${cmd_echo} ${_output} | ${cmd_jq} 'if(try.data[0].'${_resource}') then .data[0].'${_resource}' else [] end' )
      ;;
    esac

    _json_timestamp=$( ${cmd_echo} ${_output} | ${cmd_jq} -c 'try.date' )

    [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  fi

  # write json
  ## configuration
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.data[0].'${_resource_name}'    |=.+ '"${_json_resource}" )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.date                           |=.+ '"${_json_timestamp}" )
  
  # ## status
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.status.cloud                   |=.+ "'"${_cloud_name}"'"' )
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.status.type                    |=.+ "'"${_resource_name}"'"' )

  # output
  _exit_string=${_json}

  ${cmd_echo} ${_exit_string}
  return ${_exit_code}

}
