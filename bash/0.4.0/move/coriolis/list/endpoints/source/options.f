move.coriolis.list.endpoints.source.options() {
  # local variables
  local _path=~move/coriolis

  # argument variables
  local _type=
  local _endpoint=
  local _filter=

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -e | --endpoint | -n | --name | -h | --host )
        shift
        _endpoint=$( ${cmd_echo} "${1}" | lcase )
      ;;     
      -f | --filter )
        shift
        _filter=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -t | --type )
        shift
        _type=$( ${cmd_echo} "${1}" | lcase )
      ;; 
    esac
    shift
  done

  # main
  if    [[ ! -z ${_endpoint} ]] && \
        [[ -d ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json ]]; then
    _json= $( ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} -c '. | select( .endpoint == "'"${_endpoint}"'" )' )

  elif  [[ -d ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json ]]; then
    _json= $( ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} -c )

  fi

echo $_type

  if  [[ ! -z ${_type} ]]; then
    echo 10
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} | $cmd_jq} -r '.destination[0] | select( ."Option Name" == "'"${_type}"'" )."Possible Values"' | ${cmd_jq} '.[]' ) 




    # case ${_type} in 
    #   clusters )
    #     _json=$( ${cmd_echo} ${_json} | ${cmd_jq} | $cmd_jq} -r '.destination[0] | select( ."Option Name" == "cluster" )."Possible Values"' | ${cmd_jq} '.[]' ) 
      
    #   ;;
    #   migr_blank_templates )
    #     ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} '.migr_blank_template[].name | ascii_downcase' | ${cmd_jq} -sc '. | unique | sort | .[]' | ${cmd_jq} -r 
      
    #   ;;
    #   migr_minion_clusters )
    #     ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} '.migr_minion_cluster[].name | ascii_downcase' | ${cmd_jq} -sc '. | unique | sort | .[]' | ${cmd_jq} -r 
      
    #   ;;
    #   migr_minion_storage_domains )
    #     ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} '.migr_minion_storage_domain[].name | ascii_downcase' | ${cmd_jq} -sc '. | unique | sort | .[]' | ${cmd_jq} -r 

    #   ;;
    #   migr_template_maps )
    #     ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} '.migr_template_map[].name | ascii_downcase' | ${cmd_jq} -sc '. | unique | sort | .[]' | ${cmd_jq} -r 

    #   ;;
    #   optimized_for )
    #     ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} '.optimized_for[] | ascii_downcase'  | ${cmd_jq} -sc '. | unique | sort | .[]' | ${cmd_jq} -r

    #   ;;
    #   os_releases )
    #     ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} '.os_release[].name | ascii_downcase' | ${cmd_jq} -sc '. | unique | sort | .[]' | ${cmd_jq} -r 

    #   ;;
    #   # vm_pools )
    #   #   ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} '.vm_pool[].name | ascii_downcase' | ${cmd_jq} -sc '. | unique | sort | .[]' | ${cmd_jq} -r 

    #   # ;;
      
    # esac
  
  else
  echo 20
    _json=$( ${cmd_cat} ${_path}/${MOVE_PROFILE}/endpoints/options/source/*.json | ${cmd_jq} -c )

  fi



  ${cmd_echo} ${_json} | ${cmd_jq} -sc



  return ${_exit_code}
}