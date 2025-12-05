lab.stop.srx() {
  snmp.set.apc9211 --port 1 --power --host 192.168.1.151 --community rw --state off
}