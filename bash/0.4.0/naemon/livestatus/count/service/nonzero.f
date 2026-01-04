naemon.livestatus.count.service.nonzero() {
  # variables
  local _count=0

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument varibles
  local _host=
  local _service=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -h | --host )
        shift
        _host="${1}"
      ;;
      -s | --service )
        shift
        _service="${1}"
      ;;
    esac
    shift
  done

  # main
  if  [[ ! -z ${_host} ]] && \
      [[ ! -z ${_service} ]]; then
    
    # service lookup is preflight
    if [[ $( ${cmd_echo} ${_service} | ${cmd_grep} -ic preflight ) == 0 ]]; then
      # get count of non-ok statuses for the host
      _count=$( ${cmd_echo} -e "GET services\nColumns: host_name description state\nFilter: host_name = ${_host}\nFilter: state > 0\nFilter: description ~ ${_service}\nFilter: description !~ Preflight\n" | unixcat /var/cache/naemon/live | ${cmd_wc} -l )

    # service lookup is preflight
    else 
      _count=$( ${cmd_echo} -e "GET services\nColumns: host_name description state\nFilter: host_name = ${_host}\nFilter: state > 0\nFilter: description ~ ${_service}\n" | unixcat /var/cache/naemon/live | ${cmd_wc} -l )

    fi
 
    _exit_code=${exit_ok}
  else
    _exit_code=${exit_crit}

  fi

  # exit
  _exit_string=${_count}

  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}