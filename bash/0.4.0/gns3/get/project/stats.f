gns3.get.project.stats() {
  # description

  # local variables
  local _json="{}"

  # argument variables
  local _host=
  local _output=
  local _project=
  local _protocol=http
  local _port=3080

  # parse command arguments
  while [[ ${1} != "" ]]; do
   case ${1} in 
     -h | --host )
        shift
        _host=${1}
     ;; 
     -o | --output )
        shift
        _output=${1}
     ;;
     -p | --port )
        shift
        _port=${1}
     ;;
     -P | --project )
        shift
        _project=${1}
     ;;
     -s | --secure )
        _protocol=https
     ;;
    esac
    shift
  done

  # main
  if [[ -z ${_filter} ]]; then
    _json=$( /bin/curl ${_protocol}://${_host}:${_port}/v2/projects/${_project}/stats 2>/dev/null | /bin/jq -c )

  else
    _json=$( /bin/curl ${_protocol}://${_host}:${_port}/v2/projects/${_project}/stats 2>/dev/null | /bin/jq -c '[ .[] | select( .name == "'"${_filter}"'" ) ]' )

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      name                ) /bin/echo ${_json} | /bin/jq -r '.[].name'                 ;;
      *                   ) /bin/echo "[]"                                             ;;
    esac

  else
    /bin/echo ${_json}

  fi
}
