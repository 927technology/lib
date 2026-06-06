naemon.restart() {
  # local variables
  # none

  # argument variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local pid=

  # parse arguments
  # none

  # main
  # verify naemon config
  ${cmd_naemon} --verify-config /etc/naemon/naemon.cfg > /dev/null 2>&1

  # restart if config passes
  if [[ ${?} == ${exit_ok} ]]; then
    for pid in $( ${cmd_osqueryi} --json "select name,pid,parent from processes where name == 'naemon' and parent == 1;" | ${cmd_jq} -r '.[].pid' ); do
      ${cmd_kill} -HUP ${pid}

      if [[ ${?} == ${exit_ok} ]]; then
        shell.log "${FUNCNAME} - [SUCCESS] Restarting Naemon PID: ${pid}"
        _exit_code=${exit_ok}

      else
        shell.log "${FUNCNAME} - [FAILURE] Restarting Naemon PID: ${pid}"
        _exit_code=${exit_crit}

      fi
    done
  else
    shell.log "${FUNCNAME} - [FAILURE] Naemon Failed Configuration Validaton"
        _exit_code=${exit_crit}

  fi

  # exit
  return ${_exit_code}
}