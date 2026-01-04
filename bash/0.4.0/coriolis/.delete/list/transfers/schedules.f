coriolis.list.transfers.schedules() {
  # local variables
  local _path_intel=~move/coriolis/intel

  # argument variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  ${cmd_cat} ${_path_intel}/transfers/schedules*.json 2>/dev/null | ${cmd_jq} -sc && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  return ${_exit_code}
}