move.coriolis.delete.transfer() {
  # local variables
  local _json=
  local _path=~move/move

  # argument variables
  local _id=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -i | --id )
        shift
        _id="${1}"
      ;;
      -h | --host )
        shift
        _host="${1}"
      ;;
    esac
    shift
  done

  # main
  # update transfers cache
  >&2 ${cmd_echo} $( date.pretty ) - Updating Coriolis Transfer Cache
  coriolis.get.transfers

  _json=$( coriolis.list.transfers | ${cmd_jq} '.[] | select( .ID == "'${_id}'" )' )

  if [[ $( ${cmd_echo} ${_json} | ${cmd_jq} 'if( ."Last Execution Status" == "UNEXECUTED" ) then '${true}' else '${false}' end' ) == ${true} ]]; then
    >&2 ${cmd_echo} $( date.pretty ) - Deleting transfer for $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.Instances' )$( ${cmd_echo} ${_json} | ${cmd_jq} -r 'if( .Notes != null ) then ( ":" + .Notes ) else empty end' ) ID:${_id}

#     cat << EOF.Transfer
# ${cmd_coriolis}                                                                                           
#   transfer                                                                                                
#   delete                                                                                                  
#   ${_id} 
# EOF.Transfer

    # create the transfer
    ${cmd_coriolis}   \
      transfer        \
      delete          \
      ${_id} > /dev/null 2>&1

    [[ ${?} == ${exit_ok} ]] && >&2 ${cmd_echo} $( date.pretty ) - Complete || >&2 ${cmd_echo} $( date.pretty ) - failure

  else
    >&2 ${cmd_echo} $( date.pretty ) - No unexecuted transfer found for ID:${_id}
    >&2 ${cmd_echo} $( date.pretty ) - failure
  fi


}

# {
#   "id": "6384cd33-d35d-4311-906b-b6083b9aaa22",
#   "created": "2025-09-11T13:47:37.000000",
#   "last_updated": null,
#   "scenario_type": "live_migration",
#   "reservation_id": "c31b3c9a-f60d-4331-9b2a-3b1ed9e8537a",
#   "instances": "\"CoriolisOL8-0\"",
#   "notes": null,
#   "origin_endpoint_id": "5908b28a-82b8-4385-81c9-6f7e39dcedc0",
#   "origin_minion_pool_id": null,
#   "destination_endpoint_id": "490a3b67-8cbc-4b7a-9dd5-d3a8df1400ef",
#   "destination_minion_pool_id": null,
#   "instance_osmorphing_minion_pool_mappings": "{}",
#   "destination_environment": "{\n  \"cluster\": \"LS1KVMGP02\",\n  \"delete_protected\": false,\n  \"leave_migrated_vms_off\": false,\n  \"migr_blank_template\": \"00000000-0000-0000-0000-000000000000\",\n  \"migr_minion_storage_domain\": \"LS1SDGP0201\",\n  \"optimized_for\": \"server\",\n  \"os_release\": \"ol_8x64\",\n  \"set_dhcp\": false,\n  \"storage_mappings\": {\n    \"disk_mappings\": [\n      {\n        \"disk_id\": \"2000\",\n        \"destination\": \"ls1sdgp0201\"\n      }\n    ]\n  },\n  \"network_map\": {\n    \"VC01-A4DVS-42-159-150-0\": \"490a3b67-8cbc-4b7a-9dd5-d3a8df1400ef\"\n  }\n}",
#   "source_environment": "{\n  \"vixdisklib_compatibility_version\": \"8.0\",\n  \"automatically_enable_cbt\": true\n}",
#   "network_map": "{\n  \"VC01-A4DVS-42-159-150-0\": \"490a3b67-8cbc-4b7a-9dd5-d3a8df1400ef\"\n}",
#   "disk_storage_mappings": "'2000'='ls1sdgp0201'",
#   "storage_backend_mappings": "",
#   "default_storage_backend": null,
#   "user_scripts": "{\n  \"global\": {},\n  \"instances\": {}\n}",
#   "clone_disks": true,
#   "skip_os_morphing": false,
#   "executions": ""
# }
