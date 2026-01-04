move.reload() {
  # global variables
  # none

  # argument variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  # clear shell
  reset

  # source environment
  . /usr/local/bin/entrypoint.f

  # exit
  return ${exit_ok}

}