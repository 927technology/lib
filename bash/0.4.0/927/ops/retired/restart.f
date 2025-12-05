927.ops.restart () {
  # description
  # restarts ops engine
  # accepts 0 arguments

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v

  # arguments variables
  local _role=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # local variables
  local _cmd=
  local _pid=
  local _process_name=
  local _process_name_pretty=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -r | --role )
        shift
        _role=${1}
      ;;
    esac
    shift
  done


  # main

  case ${_role} in
    jobserver ) 
      _process_name=gearmand
      _process_name_pretty="Job Server"
      _cmd="${cmd_gearmand} -d --log-file none --syslog $OPTIONS"
    ;;
    manager ) 
      _process_name=naemon
      _process_name_pretty="Manager"
      _cmd="${cmd_naemon} --daemon ${path_naemon}/naemon.cfg"
    ;;
    workerserver )
      _process_name=mod_gearman_worker
      _process_name_pretty="Worker Server"
      _cmd="${cmd_mod_gearman_worker} -d --config=/etc/mod_gearman/worker.conf"
    ;;
    * )
      echo wtf **${_role}**
    ;;
  esac

  if [[ ! -z {_role} ]]; then
    if [[ $( ${cmd_osqueryi} "select pid from processes where name == '${_process_name}' and parent == 1" --json | ${cmd_jq} -c '.[]' | ${cmd_wc} -l ) == 0 ]]; then
      eval ${_cmd}
      _exit_code=${exit_ok}
      _exit_string="starting ${_process_name_pretty}"

    else
      _pid=$( ${cmd_osqueryi} "select pid from processes where name == '${_process_name}' and parent == 1" --json | ${cmd_jq} -r '.[0].pid' )
      ${cmd_kill} -HUP ${_pid}
      _exit_code=${exit_ok}
      _exit_string="restarting ${_process_name_pretty}"
    fi
  fi


  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}