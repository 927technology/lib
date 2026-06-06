move.start() {
  # local variables
  local _count=0
  local _endpoint_destination=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local host=
  local harddisk=

  # argument variables
  local _json=
  local _name=
  local _profile=
  local _type=
  local _verbose=${false}

  # parse arguments
  while [[ "${1}" != "" ]]; do 
    case "${1}" in
      -p | --profile )
        shift
        _profile="${1}"
      ;;
      -v | --verbose )
        _verbose="${true}"
      ;;
     esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && return ${exit_crit}

  # pretty print
  if [[ ${_verbose} == ${false} ]]; then
    vsphere.get.vms --search connect 2>&1 | ${cmd_awk} -F" - " '{print $NF}' >&2
    ${cmd_echo}
    coriolis.update.cache 2>&1 | ${cmd_awk} -F" - " '{print $NF}' >&2
    ${cmd_echo}
    move.create.vms 2>&1 | ${cmd_awk} -F" - " '{print $NF}' >&2
    ${cmd_echo}
    
  else
    vsphere.get.vms --search connect
    ${cmd_echo}
    coriolis.update.cache
    ${cmd_echo}
    move.create.vms
    ${cmd_echo}
  fi

  ${cmd_echo} Disabled Transfers
  for host in $( move.list.transfers --disable --output name ); do
    if [[ ${_verbose} == ${false} ]]; then
      shell.log "${FUNCNAME}(${_profile}) - [ENABLE]      move.set.transfers --name ${host} --key .move.coriolis.enable --value ${true}" 2>&1 | ${cmd_awk} -F" - " '{print $NF}' >&2

    else
      shell.log "${FUNCNAME}(${_profile}) - [ENABLE]      move.set.transfers --name ${host} --key .move.coriolis.enable --value ${true}"
  
    fi
  done
  ${cmd_echo}
  
  ${cmd_echo} Enabled Transfers
  for host in $( move.list.transfers --enable --output name ); do
    if [[ ${_verbose} == ${false} ]]; then
      shell.log "${FUNCNAME}(${_profile}) - [DISABLE]      move.set.transfers --name ${host} --key .move.coriolis.enable --value ${false}" 2>&1 | ${cmd_awk} -F" - " '{print $NF}' >&2

    else
      shell.log "${FUNCNAME}(${_profile}) - [DISABLE]      move.set.transfers --name ${host} --key .move.coriolis.enable --value ${false}"
  
    fi
  done
  ${cmd_echo}
}