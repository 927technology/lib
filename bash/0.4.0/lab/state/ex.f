lab.state.ex() {
  case $( snmp.get.apc9211 --port 2 --power --host 192.168.1.151 --community rw ) in
    1 ) ${cmd_echo} on ;;
    2 ) ${cmd_echo} off ;;
    * ) ${cmd_echo} unknown ;;
  esac
}