date.pretty() {
  # description
  # accepts no args.  returns date in YYYY-MM-DD_HH:MM:SS

  # local variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  _exit_string=$( ${cmd_date} +'%Y-%m-%d_%H:%M:%S' )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}