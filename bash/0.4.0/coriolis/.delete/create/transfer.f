coriolis.create.transfer() {
  # local variables
  local _id=
  local _json=
  local _name=
  local _path_intel=~move/coriolis/intel
  local _path_transfers=~move/coriolis/transfers

  # argument variables
  # none

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  ${cmd_mkdir} -p ${_path_transfers}
  
  
  
  
  
  
  
  
  
  
  
  _json=$( ${cmd_coriolis} deployment list --insecure -f json 2>/dev/null | ${cmd_jq} )
  
  for deployment in $( ${cmd_echo} ${_json} | ${cmd_jq} -c '.[]' ); do
    # zero out loop variables
    _id=
    _name=

    _id=$( ${cmd_echo} ${deployment} | ${cmd_jq} -r '.ID' )
    _name=$( ${cmd_echo} ${deployment} | ${cmd_jq} -r '.Instances' | ${cmd_sed} 's/\//-/g' )

    ${cmd_echo} ${deployment} > ${_path_intel}/deployments/${_id}.json
    [[ ${?} != ${exit_ok} ]] && (( _error_count++ )) 

    # cannot do this since the same host can have multiple deployments
    # ${cmd_ln} -fs ${_id}.json ${_path_intel}/deployments/"${_name}"
  done

  [[ ${_error_count} == 0 ]] && _exit_code=${exit_ok} || _exit_code=${exit_crit}

  # exit
  return ${_exit_code}
}




{
  "leave_migrated_vms_off": false,
  "migr_blank_template": "00000000-0000-0000-0000-000000000000",
  "os_release": "other_linux",
  "cluster": "da122bd2-14d7-4e81-ae62-4ddd6da87e29",
  "migr_minion_storage_domain": "45d9575c-29cd-474a-916a-ab5d358418d9",
  "migr_minion_cluster": "da122bd2-14d7-4e81-ae62-4ddd6da87e29",
  "migr_template_map": {
    "linux": "968f167c-ffdf-4085-b347-5b22741142e6"
  },
  "network_map": {
    "ESX-Management-Compute-AZ2": "d098bb12-c918-48ba-bf8f-c09bdb148efb"
  },
  "storage_mappings": {
    "default": "pocDC2","backend_mappings": [
      {
        "source": "AZ2-VMFS-1",
        "destination": "pocDC2"
      }
    ],
    "disk_mappings": [
      {
        "disk_id": "2000",
        "destination": "pocDC2"
      }
    ]
  }
}