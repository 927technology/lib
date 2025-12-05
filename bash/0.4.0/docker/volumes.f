docker.volumes () {
  # description outputting a list of volumes within /usr/bin/docker 
  # in json format  using the slurp and compact options

  # accepts zero arguments

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
  _json=$( ${cmd_docker} volume ls --format='{{json .}}' | ${cmd_jq} -sc )
  [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}