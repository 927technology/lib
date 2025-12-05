docker.images () {
  # description 
  # outputing the docker images on the host machine out images on the host as json
  # accept zero arguments 

  # local variables
  local _count=0
  local _json="{}"

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  _json=$( ${cmd_docker} images --format='{{json .}}' | ${cmd_jq} -sc )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  _exit_string=${_json}
  
  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}