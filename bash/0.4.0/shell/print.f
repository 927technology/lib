shell.print() {
  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables

  # argument variables
  local _string=${1}

  # parse arguments
  # none


  # main
  if [[ ! -z ${_string}  ]]; then
    ${cmd_echo} ${_string}
    _exit_code=${?}

  else
    _exit_code=${exit_crit}

  fi

  # exit
  return ${_exit_code}
}