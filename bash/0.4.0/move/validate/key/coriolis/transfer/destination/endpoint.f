move.validate.key.coriolis_transfer_destination_endpoint() {
  # local variables
  local _direction=destination

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  # none

  # parse arguments
  # none

  # main
  # [[ -z ${_profile} ]] && return ${exit_crit}

  move.validate.key.coriolis_transfer_endpoint --direction ${_direction} ${@} || (( _error_count++ ))

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}