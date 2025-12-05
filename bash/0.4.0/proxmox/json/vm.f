proxmox.json.vm() {
  # dependancies

  # local variables
  local _json="{}"

  # argument variables
  local _args=
  local _cores=
  local _cd_rom=
  local _memory=
  local _name=
  local _network=
  local _os_type=
  local _scsi0=
  local _storage=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  
  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -a | --args )
        shift
        _args="${1}"
      ;;        
      -c | --cores )
        shift
        _cores="${1}"
      ;;      
      -cd | --cd-rom )
        shift
        _cd_rom="${1}"
      ;;
      -m | --memory )
        shift
        _memory="${1}"
      ;;      
      -n | --name )
        shift
        _name="${1}"
      ;;      
      -N | --network )
        shift
        _network="${1}"
      ;;
      -os  | --os-type )
        shift
        case $( ${cmd_echo} "${1}" | lcase ) in
          wxp     | winxp         | windows_xp    ) _os_type=wxp      ;;
          w2k     | win2k         | windows_2000  ) _os_type=w2k      ;;
          w2k3    | win2k3        | windows_2003  ) _os_type=w2k3     ;;
          w2k8    | win2k8        | windows_2008  ) _os_type=w2k8     ;;
          wvista  | vista         | windows_vista ) _os_type=wvista   ;;
          w7      | win7          | windows_7     ) _os_type=win7     ;;
          w8      | win8          | windows_8     ) _os_type=win8     ;;
          w10     | win10         | windows_10    ) _os_type=win10    ;;
          w11     | win11         | windows_11    ) _os_type=win11    ;;
          l24     | linux_legacy                  ) _os_type=l24      ;;
          l26     | linux                         ) _os_type=l26      ;;
          solaris                                 ) _os_type=solaris  ;;
          *                                       ) _os_type=other    ;;
        esac
      ;;
      -s | --storage )
        shift
        _storage="${1}"
      ;;
      -s0 | --scsi0 )
        shift
        _scsi0="${1}"
      ;;
    esac
    shift
  done

  # control variables
  # none

  # main
  _json=$( json.set --json ${_json} --key .vmid     --value 107    )
  _json=$( json.set --json ${_json} --key .name     --value ${_name}    )
  _json=$( json.set --json ${_json} --key .ostype   --value ${_os_type} )
  _json=$( json.set --json ${_json} --key .memory   --value ${_memory}  )
  _json=$( json.set --json ${_json} --key .node     --value vmh-01  )
  _json=$( json.set --json ${_json} --key .cores    --value ${_cores}   )
  _json=$( json.set --json ${_json} --key .storage  --value ${_storage} )
  _json=$( json.set --json ${_json} --key .net0     --value ${_network} )
  _json=$( json.set --json ${_json} --key .cdrom    --value ${_cd_rom}  )
  _json=$( json.set --json ${_json} --key .scsi0    --value ${_scsi0}  )
  _json=$( json.set --json ${_json} --key .args    --value "${_args}"  )

  ${cmd_echo} ${_json} | is_json >/dev/null 2>&1 || (( _error_count++ ))

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  ${cmd_echo} ${_json} | ${cmd_jq} -c
  return ${_exit_code}
}

# {
#   "vmid": 100,
#   "name": "myvm",
#   "ostype": "l26",
#   "memory": 1024,
#   "cores": 1,
#   "storage": "local",
#   "net0": "virtio,bridge=vmbr0",
#   "ide2": "local:iso/ubuntu-20.04.iso"
# }