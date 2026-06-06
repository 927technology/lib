move.validate.vsphere.guestid() {
  #_description: Validate the GuestID key is set to windows or linux
  #_filter: false
  #_name: true
  #_arguments: --id,--name,--output,--status
  #_output: none
  
  # local variables
  local _json=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=


  # argument variables
  local _name=
  local _profile=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter | -h | --host | -n | --name )
        shift
        _name=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
     esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  if   [[ ! -z ${_name} ]]; then
    _json=$( move.vsphere.list.vms --name ${_name} --profile ${_profile} | ${cmd_jq} -c '.[]' )

  fi

  case $( ${cmd_echo} ${_json} | ${cmd_jq} -r 'try( .GuestID )' ) in
    *Linux*Guest | windows*Guest )
      shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [VALID]  GuestID: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.GuestID' ), VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.Name' )"

    ;;
    * )
      shell.log "${_exit_string}${FUNCNAME}(${_profile}) - [INVALID]  GuestID: $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.GuestID' ), VM: $( ${cmd_echo} "${_json}" | ${cmd_jq} -r '.Name' )"
      (( _error_count++ ))
    
    ;;
  esac

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}