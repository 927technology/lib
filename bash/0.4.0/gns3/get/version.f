gns3.get.version() {
  # description

  # local variables
  # none

  # argument variables
  local _host=
  local _protocol=http
  local _port=3080

  # parse command arguments
  while [[ ${1} != "" ]]; do
   case ${1} in 
     -h | --host )
        shift
        _host=${1}
     ;; 
     -p | --port )
        shift
        _port=${1}
     ;;
     -s | --secure )
        _protocol=https
     ;;
    esac
    shift
  done

  # main
  /bin/curl ${_protocol}://${_host}:${_port}/v2/version 2>/dev/null | /bin/jq -c
}
