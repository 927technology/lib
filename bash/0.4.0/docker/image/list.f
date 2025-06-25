docker.image.list() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_image=0
  local _json="{}"
  local -a _json_image=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  # none
  
  # parse arguments
  # none

  # main
  # itterate images
  for image in $( ${cmd_docker} ps --all --format='{{json .}}' | ${cmd_jq} -c ); do
    
    # add image to json
    _json_image[${_count_image}]="${image}"
    [[ ${?} == ${exit_ok} ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}
    
    (( _count_image++ ))
  done
  
  # build json list form _json_image array
  _json=$( ${cmd_echo} "${_json_image[@]}" | ${cmd_jq} -sc )

  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}