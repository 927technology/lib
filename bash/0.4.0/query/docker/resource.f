function query.docker.resource {
  # accepts 1 argument osuquery, returns json

  #local variables
  local _err_count=0
  local _exit_code=${exit_unkn}
  local _json="{}"
  local _osquery=${false}
  local _resource=
  local _sanity=${false}

  # parse command arguments
  [[ ${1} != "" ]] && _resource="${1}"
  shift

  while [[ ${1} != "" ]]; do
    case ${1} in
      -o | --osquery )
        _osquery=${true}
      ;;
    esac
    shift
  done

  #main
  case ${_resource} in
    image | images )
      _docker_query='images'
      _osquery_query='select * from docker_images;'
      _sanity=${true}
    ;;
    image_layer | image_layers )
      _docker_query=
      _osquery_query='select * from docker_image_layers;'
      _sanity=${true}
    ;;
    info )
      _docker_query='info'
      _osquery_query='select * from docker_info;'
      _sanity=${true}
    ;;
    network | networks )
      _docker_query='networks'
      _osquery_query='select * from docker_networks;'
      _sanity=${true}
    ;;
    version )
      _docker_query='version'
      _osquery_query='select * from docker_version;'
      _sanity=${true}
    ;;
    volume | volumes )
      _docker_query='volume ls'
      _osquery_query='select * from docker_volumes;'
      _sanity=${true}
    ;;
    * )
      (( _err_count++ ))
    ;;
  esac

  if [[ ${_osquery} == ${true} ]] && [[ -f ${cmd_osqueryi} ]] && [[ ${_sanity} == ${true} ]]; then
    _json=$( ${cmd_osqueryi} "${_osquery_query}" --json | ${cmd_jq} -c 2>/dev/null)

    [[ ${?} != ${exit_ok} ]]                                          && (( _exit_code++ ))

  elif [[ ${_osquery} == ${false} ]] && [[ -f ${cmd_docker} ]] && [[ ${_sanity} == ${_true} ]]; then
    case ${_resource} in 
      image_layer | image_layers )
        _json=$( ${cmd_docker} inspect $( ${cmd_docker} images --format json | ${cmd_jq} -r ".ID" ) | ${cmd_jq} '.[].RootFS.Layers' | ${cmd_jq} '.[] | split(":")[1]' | ${cmd_jq} -s ". | sort | unique" 2>/dev/null)
      ;;
      * )
        _json=$( ${cmd_docker} ${_docker_query} --format json | ${cmd_jq} -s | ${cmd_jq} -c 2>/dev/null)
      ;;
    esac

    [[ ${?} != ${exit_ok} ]]                                          && (( _exit_code++ ))

  else
    _json="[]"
    (( _err_code++ ))
  fi

  # exit status
  [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  _exit_string="${_json}"

  #return
  ${cmd_echo} "${_exit_string}"
  return ${_exit_code}
}