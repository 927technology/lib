move.edit.network.map() {
  # local variables
  local _path=~move/move

  # argument variables
  local _network=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -n | --network )
        shift
        _network="${1}"
      ;;
    esac
    shift
  done

  # main
  if [[ -f ${_path}/networks/${_network}.json ]]; then
    ${cmd_vi} ${_path}/networks/${_network}.json
  
  else
    ${cmd_echo} Available Network Names
    ${cmd_echo} ----------------------------
    move.list.network.map --short

    ${cmd_echo}
    ${cmd_echo} Usage:
    ${cmd_echo} "move.edit.network.map --network <network name>"
    ${cmd_echo}
  fi
  
  # exit
  return ${?}
}