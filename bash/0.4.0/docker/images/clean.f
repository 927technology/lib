docker.images.clean () {
  IFS=$'\n' # because IFS sucks
  # description

  # dependancies
  # json/images

  # local variables
  local _json=$( docker.images )

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  for image in $( ${cmd_echo} ${_json} | ${cmd_jq} -cr '.[] | if(.Repository == .ID) then .ID else empty end' ); do 
    ${cmd_docker} rmi ${image} || (( _error_count++ ))
  done

  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}