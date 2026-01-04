vsphere.list.vms.stats() {
  # local variables
  local _json=

  # argument variables
  #none 

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  _json=$( vmware.list.vms | jq '.[] | {"name":.name, "harddisks":(.harddisks | length), "networkadapters":(.networkadapters | length)}' | ${cmd_jq} -sc )
  if [[ ${?} == ${exit_ok} ]]; then
    _exit_code=${exit_ok}
  
  else
    _exit_code=${exit_crit}

  fi

  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_exit_string} | ${cmd_jq}
  return ${_exit_code}
}



