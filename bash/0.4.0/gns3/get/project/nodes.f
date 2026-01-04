gns3.get.project.nodes() {
  # description

  # local variables
  local _json="{}"

  # argument variables
  local _host=
  local _output=
  local _project=
  local _protocol=http
  local _port=3080
  local _type=

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
     -t | --type )
        shift
        _type=${1}
     ;;
    esac
    shift
  done

  # main
  if [[ -z ${_filter} ]]; then
    _json=$( /bin/curl ${_protocol}://${_host}:${_port}/v2/projects/${_project}/nodes 2>/dev/null | /bin/jq -c )

  else
    _json=$( /bin/curl ${_protocol}://${_host}:${_port}/v2/projects{_project}/nodes 2>/dev/null | /bin/jq -c '[ .[] | select( .name == "'"${_filter}"'" ) ] | sort_by(.name)' )

  fi

  if [[ ! -z ${_type} ]]; then
    _json=$( /bin/echo ${_json} | /bin/jq -c '[ .[] | select( .node_type == "'"${_type}"'" ) ]' )

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      compute_id          ) /bin/echo ${_json} | /bin/jq -r '.[].compute_id'           ;;
      console             ) /bin/echo ${_json} | /bin/jq -r '.[].console'              ;;
      console_auto_start  ) /bin/echo ${_json} | /bin/jq -r '.[].console_auto_start'   ;;
      console_type        ) /bin/echo ${_json} | /bin/jq -r '.[].console_type'         ;;
      custom_adapters     ) /bin/echo ${_json} | /bin/jq -r '.[].custom_adapters'      ;;
      first_port_name     ) /bin/echo ${_json} | /bin/jq -r '.[].first_port_name'      ;;
      height              ) /bin/echo ${_json} | /bin/jq -r '.[].height'               ;;
      label               ) /bin/echo ${_json} | /bin/jq -r '.[].label'                ;;
      locked              ) /bin/echo ${_json} | /bin/jq -r '.[].locked'               ;;
      name                ) /bin/echo ${_json} | /bin/jq -r '.[].name'                 ;;
      node_id             ) /bin/echo ${_json} | /bin/jq -r '.[].node_id'              ;;
      node_type           ) /bin/echo ${_json} | /bin/jq -r '.[].node_type'            ;;
      port_name_format    ) /bin/echo ${_json} | /bin/jq -r '.[].port_name_format'     ;;
      port_segment_size   ) /bin/echo ${_json} | /bin/jq -r '.[].port_segment_size'    ;;
      properties          ) /bin/echo ${_json} | /bin/jq -r '.[].properties'           ;;
      symbol              ) /bin/echo ${_json} | /bin/jq -r '.[].symbol'               ;;
      template_id         ) /bin/echo ${_json} | /bin/jq -r '.[].template_id'          ;;
      width               ) /bin/echo ${_json} | /bin/jq -r '.[].width'                ;;
      x                   ) /bin/echo ${_json} | /bin/jq -r '.[].x'                    ;;
      y                   ) /bin/echo ${_json} | /bin/jq -r '.[].y'                    ;;
      z                   ) /bin/echo ${_json} | /bin/jq -r '.[].z'                    ;;
      *                   ) /bin/echo "[]"                                             ;;
    esac

  else
    /bin/echo ${_json}

  fi
}
