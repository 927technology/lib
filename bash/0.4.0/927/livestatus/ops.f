927.livestatus.ops () {
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

  # ifs
  IFS=$'\n'

  # argument variables
  local _type=


  # control variables
  local _col=0
  local _error_count=0
  local _index=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # variables
  local _brief=${false}
  local _json="{}"
  local _json_header="{}"
  local _json_livestatus=
  local _exit_resource=
  local _query=

  
  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -b | --brief )
        _brief=${true}
      ;;
      -t | --type )
        shift
        _type=${1}
      ;;
    esac
    shift
  done


  # main
  if [[ ! -z ${_type}           ]] ||
     [[ ${type} == host[s]?     ]] ||
     [[ ${type} == service[s]?  ]]; then

    case ${_type} in
      host | hosts )
        if [[ ${_brief} == ${true} ]]; then
          _query="GET hosts\nColumns: name display_name\nColumnHeaders: on\n"
        else  
          _query="GET hosts\n"
        fi
      ;;
      service | services )
        if [[ ${_brief} == ${true} ]]; then
          _query="GET services\nColumns: description display_name host_name\nColumnHeaders: on\n"
        else  
          _query="GET services\n"
        fi
      ;;
    esac


    for type in $( ${cmd_printf} "${_query}" | ${cmd_unixcat} /var/cache/naemon/live | ${cmd_tail} -n +2 ); do
      _value=
      _col=0

      for header in $( ${cmd_printf} "${_query}" | ${cmd_unixcat} /var/cache/naemon/live | ${cmd_head} -n 1 | ${cmd_sed} 's/;/\n/g' ); do 
        (( _col++ ))

        if [[ ${header} != services_with_info       ]] &&
           [[ ${header} != custom_variables         ]] &&
           [[ ${header} != custom_variable_values   ]] &&
           [[ ${header} != depends_notify           ]] &&
           [[ ${header} != depends_notify_with_info ]] &&
           [[ ${header} != host_long_plugin_output  ]] &&
           [[ ${header} != host_custom_variable_values ]] &&
           [[ ${header} != host_custom_variables ]] &&
           [[ ${header} != host_services_with_info ]] &&
           [[ ${header} != plugin_output ]]; then
          _value=$( ${cmd_echo} ${type} | ${cmd_awk} -F";" '{print $'${_col}'}' )
          [[ ${_value} == "-" ]] && _value=
          _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.data['${_index}'].'${header}'   |=.+ "'"${_value}"'"' )
        fi

      done

      (( _index++ ))
    done
  fi

  ${cmd_echo} ${_json} | ${cmd_jq} -c
}