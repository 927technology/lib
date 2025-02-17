docker.images.clean () {
  # local variables
  local _count=0
  local _err_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _json=

  # parse command arguments
  ## none

  # main

  for image in $( ${cmd_docker} images | ${cmd_grep} none ); do 
    ${cmd_docker} rmi ${cmd_echo} ${image} | ${cmd_awk} '{print $3}'    || (( _err_count++ ))
    (( count++ ))
  done

  [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit}

  _exit_string="${_count} images cleaned"

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}