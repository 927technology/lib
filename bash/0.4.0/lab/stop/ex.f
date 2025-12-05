lab.stop.ex() {
  snmp.set.apc9211 --port 2 --power --host 192.168.1.151 --community rw --state off
}