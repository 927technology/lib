gns3.get.projects() {
  # description

  # local variables
  # none

  # argument variables
  local _filter=
  local _json="{}"
  local _host=
  local _protocol=http
  local _port=3080

  # parse command arguments
  while [[ ${1} != "" ]]; do
   case ${1} in 
     -f | --filter )
       shift
       _filter=${1}
     ;;
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
     -s | --secure )
       _protocol=https
     ;;
    esac
    shift
  done

  # main
  if [[ -z ${_filter} ]]; then
    _json=$( /bin/curl ${_protocol}://${_host}:${_port}/v2/projects 2>/dev/null | /bin/jq -c )

  else
    _json=$( /bin/curl ${_protocol}://${_host}:${_port}/v2/projects 2>/dev/null | /bin/jq -c '[ .[] | select( .name == "'"${_filter}"'" ) ]' )

  fi

  if [[ ! -z ${_output} ]]; then
    case ${_output} in
      auto_close            ) /bin/echo ${_json} | /bin/jq -r '.[].auto_close'              ;;
      auto_open             ) /bin/echo ${_json} | /bin/jq -r '.[].auto_open'               ;;
      auto_start            ) /bin/echo ${_json} | /bin/jq -r '.[].auto_start'              ;;
      drawing_grid_size     ) /bin/echo ${_json} | /bin/jq -r '.[].drawing_grid_size'       ;;
      filename              ) /bin/echo ${_json} | /bin/jq -r '.[].filename'                ;;
      grid_size             ) /bin/echo ${_json} | /bin/jq -r '.[].gird_size'               ;;
      name                  ) /bin/echo ${_json} | /bin/jq -r '.[].name'                    ;;
      path                  ) /bin/echo ${_json} | /bin/jq -r '.[].path'                    ;;
      id                    ) /bin/echo ${_json} | /bin/jq -r '.[].project_id'              ;;
      scene_height          ) /bin/echo ${_json} | /bin/jq -r '.[].scene_height'            ;;
      scene_width           ) /bin/echo ${_json} | /bin/jq -r '.[].scene_width'             ;;
      show_grid             ) /bin/echo ${_json} | /bin/jq -r '.[].show_grid'               ;;
      show_interface_labels ) /bin/echo ${_json} | /bin/jq -r '.[].show_interface_labels'   ;;
      show_layers           ) /bin/echo ${_json} | /bin/jq -r '.[].show_layers'             ;;
      snap_to_grid          ) /bin/echo ${_json} | /bin/jq -r '.[].snap_to_grid'            ;;
      status                ) /bin/echo ${_json} | /bin/jq -r '.[].status'                  ;;
      supplier              ) /bin/echo ${_json} | /bin/jq -r '.[].supplier'                ;;
      variables             ) /bin/echo ${_json} | /bin/jq -r '.[].variables'               ;;
      zoom                  ) /bin/echo ${_json} | /bin/jq -r '.[].zoom'                    ;;
      *                     ) /bin/echo "[]"                                               ;;
    esac

  else
    /bin/echo ${_json}

  fi
}
