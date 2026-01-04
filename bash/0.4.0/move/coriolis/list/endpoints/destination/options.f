move.coriolis.list.endpoints.destination.options() {

  IFS=$'\n'.   # because IFS sucks

  # local variables
  local _json=
  local _json_type=
  local _path=~move/coriolis

  # argument variables
  local _endpoint=
  local _name=
  local _output=
  local _type=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -e | --endpoint )
        shift
        _endpoint=$( ${cmd_echo} "${1}" | lcase )
      ;;     
      -h | --host | --n | --name )
        shift
        _name=$( ${cmd_echo} "${1}" | ucase )
      ;;
      -o | --output )
        shift
        _output=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -t | --type )
        shift
        _type=$( ${cmd_echo} "${1}" | lcase )
      ;; 
    esac
    shift
  done

  # main
  # endpoint is defined
  if    [[ ! -z ${_endpoint}                                                ]] && \
        [[ -d ${_path}/${MOVE_PROFILE}/endpoints/options/destination/*.json ]]; then
    _json=$( ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/destination/*.json | ${cmd_jq} -c '.destination[] | select( .endpoint == "'"${_endpoint}"'" )' )

  # endpoint is not defined
  elif  [[ -d ${_path}/${MOVE_PROFILE}/endpoints/options/destination        ]]; then
    _json=$( ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/destination/*.json | ${cmd_jq} -c '.destination[]' )

  fi

  # type filter is defined
  if  [[ ! -z ${_type} ]]; then
    for destination in "${_json}"; do 
      # aliases for us lazy folk
      [[ ${_type} == "minion" ]] && _type=migr_template_map
      [[ ${_type} == "os"     ]] && _type=os_release

      # sanitize inputs
      if  [[ ${_type} == "cluster"                    ]] || \
          [[ ${_type} == "migr_blank_template"        ]] || \
          [[ ${_type} == "migr_minion_cluster"        ]] || \
          [[ ${_type} == "migr_minion_storage_domain" ]] || \
          [[ ${_type} == "storage_mappings"           ]] || \
          [[ ${_type} == "migr_template_map"          ]] || \
          [[ ${_type} == "optimized_for"              ]] || \
          [[ ${_type} == "os_release"                 ]] || \
          [[ ${_type} == "vm_pool"                    ]]; then

        # coriolis does not have a type for storage_mappings, subsituting migr_minoin_storage_domain
        case ${_type} in
          storage_mappings )
            _json_type=${_json_type}$( ${cmd_echo} ${destination} | ${cmd_jq} -r '. | select( ."Option Name" == "migr_minion_storage_domain" )."Possible Values"' | ${cmd_jq} -c '.[]' )

          ;;
          * )
            _json_type=${_json_type}$( ${cmd_echo} ${destination} | ${cmd_jq} -r '. | select( ."Option Name" == "'"${_type}"'" )."Possible Values"' | ${cmd_jq} -c '.[]' )
          
          ;;
        esac
      fi
    done

    _json=$( ${cmd_echo} "${_json_type}" | ${cmd_jq} -c )
  fi

  # name filter is defined
  if [[ ! -z ${_name} ]]; then
    _json=$( ${cmd_echo} "${_json}" | ${cmd_jq} -c '. | select( .name | ascii_upcase | startswith( "'"${_name} "'" ) )' )
  fi

  # output filter is defined
  if [[ ! -z ${_output} ]]; then
    if  [[ ${_type} == "migr_template_map"          ]] ||                                           \
        [[ ${_type} == "migr_blank_template"        ]] ||                                           \
        [[ ${_type} == "migr_minion_cluster"        ]] ||                                           \
        [[ ${_type} == "migr_minion_storage_domain" ]] ||                                           \
        [[ ${_type} == "storage_mappings"        ]]; then
      case ${_output} in
        id        ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.id'                                     ;;
        name      ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name'     | ${cmd_awk} '{print $1}'     ;;
        os_type   ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.os_type'                                ;;
      esac

    elif  [[ ${_type} == "optimized_for"              ]]; then
      ${cmd_echo} "${_json}" | ${cmd_jq} -r '.[]'

    elif  [[ ${_type} == "os_release"                 ]] || \
          [[ ${_type} == "cluster"                    ]]; then
      case ${_output} in
        id        ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.id'                                     ;;
        name      ) ${cmd_echo} "${_json}" | ${cmd_jq} -r '.name'                                   ;;
      esac

    fi

  else
    ${cmd_echo} "${_json}" | ${cmd_jq} -sc
  
  fi

  return ${_exit_code}
}