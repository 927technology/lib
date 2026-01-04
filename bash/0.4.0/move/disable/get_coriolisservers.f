move.get_coriolisservers() {
  # local variables
  # none

  # argument variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  ${cmd_cat} /usr/local/etc/move/connect.json | ${cmd_jq} -r '.coriolis[].name'

  # exit
  return ${_exit_code}
}