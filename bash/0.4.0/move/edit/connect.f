move.edit.connect() {
  # local variables
  # none
  
  # argument variables
  local _host=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  ${cmd_vi} /usr/local/etc/move/connect.json

  # exit
  return ${?}
}