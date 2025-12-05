proxmox.create.api() {
  # dependancies

  # local variables
  local _api_key_name=api
  # local _api_key_value=c7d9f2a8-ce86-4ae1-a51b-f187efe43db2 # svc_api
  local _api_key_value=b48aae82-7ca7-4c3b-9763-bcd1df3ec065 # root
  # local _api_user=svc_api
  local _api_user=root
  # local _api_user_realm=pve
  local _api_user_realm=pam
  local _host=192.168.1.150
  local _host_port=8006
  local _json="{}"
  local _node=vmh-01
  local _path=nodes/${_node}/qemu
  local _path_input=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # while [[ ${1} != "" ]]; do
  #   case ${1} in
  #     -akn  | --api-key-name )
  #       shift
  #       _api_key_name=$( ${cmd_echo} "${1}" | lcase )
  #     ;;
  #     -akv  | --api-key-value )
  #       shift
  #       _api_key_value=$( ${cmd_echo} "${1}" | lcase )
  #     ;;
  #     -au  | --api-user )
  #       shift
  #       _api_user=$( ${cmd_echo} "${1}" | lcase )
  #     ;;
  #     -aur  | --api-user-realm )
  #       shift
  #       _api_user_realm=$( ${cmd_echo} "${1}" | lcase )
  #     ;;
  #     -h  | --host )
  #       shift
  #       _host=$( ${cmd_echo} "${1}" | lcase )
  #     ;;
  #     -hp  | --host-port )
  #       shift
  #       _host_port=$( ${cmd_echo} "${1}" )
  #     ;;
  #     -n | --node )
  #       shift
  #       _node=$( ${cmd_echo} "${1}" | lcase )
  #     ;;
  #     -p  | --path )
  #       shift
  #       _path_input=$( ${cmd_echo} "${1}" | lcase )
  #     ;;
  #   esac
  #   shift
  # done

  # control variables
  # none

  # main
  _vm=$(                                                                                              \
    proxmox.json.vm                                                                                   \
      --name    testvm                                                                                \
      --os-type linux                                                                                 \
      --memory  1024                                                                                  \
      --cores   1                                                                                     \
      --storage local                                                                                 \
      --network "virtio,bridge=vmbr0,tag=100"                                                                 \
      --cd-rom "local:iso/Rocky-9.5-x86_64-minimal.iso"       \
      --scsi0 "local-lvm:32" \
      --args "vmlinuz initrd=initrd.img inst.stage2=hd:LABEL=Rocky-9-5-x86-64-dvd rd.live.check quiet inst.ks=https://raw.githubusercontent.com/927technology/kickstart/main/distro/el/minimal.ks"

  )

  echo $_vm | jq
echo $_host
echo $_host_port
echo $_path
echo ${_api_user}@${_api_user_realm}

  ${cmd_curl}                                                                                           \
    -k                                                                                                  \
    -X POST "https://${_host}:${_host_port}/api2/json/${_path}/"                                          \
    -H "Authorization: PVEAPIToken=${_api_user}@${_api_user_realm}!${_api_key_name}=${_api_key_value}" \
    -H "Content-Type: application/json" --data "${_vm}"



    # this works!
    # ${cmd_curl}                                                                                           \
    #   -k                                                                                                  \
    #   -X POST "https://192.168.1.150:8006/api2/json/nodes/vmh-01/qemu/"                                          \
    #   -H "Authorization: PVEAPIToken=svc_api@pve!api=c7d9f2a8-ce86-4ae1-a51b-f187efe43db2" \
    #   -H "Content-Type: application/json" --data ${_vm}

}

# curl -X POST \
#   -H "Authorization: PVEAPIToken=root@pam!TOKEN_VALUE" \
#   -H "Content-Type: application/x-www-form-urlencoded" \
#   -d "command=start" \
#   https://proxmox.example.com:8006/api2/json/nodes/pve/qemu/100/status/start   

# proxmox.get.api --host 192.168.1.150 --host-port 8006 --api-key-name api --api-key-value c7d9f2a8-ce86-4ae1-a51b-f187efe43db2 --api-user svc_api --api-user-realm pve --path node/status --node vmh-01