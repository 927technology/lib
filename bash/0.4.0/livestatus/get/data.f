livestatus.get.data() {
  # variables
  local _columns=
  local _csv=
  local _filters=
  local _host=
  local _table=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument varibles
  local _map=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host )
        shift
        _host="${1}"
      ;;
      -m | --map )
        shift
        _map="${1}"
      ;;
    esac
    shift
  done

  # main
  # columns
  if [[ $( ${cmd_echo} ${_map} | ${cmd_jq} -r '.columns | length' ) > 0 ]]; then
    _columns="Columns: "
    for column in $( ${cmd_echo} ${_map} | ${cmd_jq} -r '.columns[]' ); do
      _columns+=" ${column}"
    done
    _columns+="\n"
  fi

  # filters
  if [[ $( ${cmd_echo} ${_map} | ${cmd_jq} -r '.filters | length' ) > 0 ]]; then
    for filter in $( ${cmd_echo} ${_map} | ${cmd_jq} -c '.filters[] | select( .enable == true )' ); do
      _filters+=$( ${cmd_echo} ${filter} | ${cmd_jq} -r '"Filter: \(.column) \(.operator) \(.value)\\n"' )
    done
  fi

  if [[ ! -z ${_host} ]]; then
    _filters+=$( ${cmd_echo} -e "Filter: host_name = ${_host}\\n" )
  fi
  # table
  _table=$( ${cmd_echo} ${_map} | ${cmd_jq} -r '.table' )

  # query livestatus
  _csv=$( ${cmd_echo} -e "GET ${_table}\n${_columns}${_filters}" | unixcat /var/cache/naemon/live )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  _exit_string="${_csv}"

  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}