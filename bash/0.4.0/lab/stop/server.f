lab.stop.server() {
#   cat << EOF.proxmox > ssh proxmox
# for vm in $( /usr/bin/sudo /usr/bin/pvesh get /cluster/resources --type vm --output-format json | /usr/local/bin/jq '.[] | select( .status == "running" ).vmid' ); do 
#   /bin/echo shutting down ${vm}
#   /usr/bin/sudo /usr/sbin/qm shutdown ${vm}
# done

# EOF.proxmox



  snmp.set.apc9211 --port 3 --power --host 192.168.1.151 --community rw --state off
}
