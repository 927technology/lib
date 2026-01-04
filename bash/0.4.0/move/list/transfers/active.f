move.list.transfers.active() {
  # local variables
  local _count=0
  local _path=~move/move
  local _json="{}"
  local _tmp_file=$( ${cmd_mktemp} )


  # argument variables
  local _filter=
  local _name=
  local _output=
  local _type=transfer

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local host=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -f | --filter )
        shift
        _filter="${1}"
      ;;
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -o | --output )
        shift
        _output="${1}"
      ;;
      -t | --type )
        shift
        case "${1}" in
          deployment | transfer ) _type="${1}"                                                      ;;
          * ) _type=transfer                                                                        ;;
        esac
      ;;
    esac
    shift
  done

  # main
  # create transfer temp file
  if    [[ ! -z ${_name} ]]; then
    move.list.transfers --name ${_name} | ${cmd_jq} '.[] | {"name":.name, "transfers":( if( try( .data.transfers[-1] ) == null ) then [] else [ .data.transfers[-1] ] end ) } | [ . ]' > ${_tmp_file}

  elif  [[ ! -z ${_filter} ]]; then
    move.list.transfers --filter ${_filter} | ${cmd_jq} -c '.[] | {"name":.name, "transfers":( if( try( .data.transfers[-1] ) == null ) then [] else [ .data.transfers[-1] ] end ) } | [ . ]' > ${_tmp_file}

  else
    move.list.transfers | ${cmd_jq} -c '.[] | {"name":.name, "transfers":( if( try( .data.transfers[-1] ) == null ) then [] else [ .data.transfers[-1] ] end ) } | [ . ]' > ${_tmp_file}
  
  fi

  # itterate hosts
  for host in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c '.[]' ); do
    # find corrisponding coriolis transfer
    case $( ${cmd_echo} ${host} | ${cmd_jq} '.transfers | length' ) in
      0 ) 
        _exit_code=${exit_crit}

        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [FAILURE] Active Transfers: 0"

      ;;
      1 ) 
        _exit_code=${exit_ok}   
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCCESS] Active Transfers: 1"
        
        ;;
      * ) 
        _exit_code=${exit_warn} 
        shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [ERROR] Active Transfers: MULTIPLE"
        
        ;;
    esac

    # add name to output
    _json=$(                                                                                    \
      json.set                                                                                  \
        --json "${_json}"                                                                       \
        --key .data[${_count}].name                                                             \
        --value $( ${cmd_echo} ${host} | ${cmd_jq} '.name' )                                    \
    )

    # add id to output
    _json=$(                                                                                    \
      json.set                                                                                  \
        --json "${_json}"                                                                       \
        --key .data[${_count}].transfers.id                                                     \
        --value $( ${cmd_echo} ${host} | ${cmd_jq} '.transfers[-1].id' )                        \
    )

    # add length to output
    _json=$(                                                                                    \
      json.set                                                                                  \
        --json "${_json}"                                                                       \
        --key .data[${_count}].transfers.count                                                  \
        --value $( ${cmd_echo} ${host} | ${cmd_jq} '.transfers | length' )                      \
    )

    if  [[ ! -z ${_output} ]] &&                                                                \
        [[ $( ${cmd_echo} ${host} | ${cmd_jq} '.transfers | length' ) == 1 ]]; then
      case ${_output} in
        id        ) ${cmd_echo} ${host} | ${cmd_jq} -r '.transfers[-1].id'                      ;;
        name      ) ${cmd_echo} ${host} | ${cmd_jq} -r '.name'                                  ;;
      
      esac

    fi

    (( _count++ ))
  done

  [[ -z ${_output} ]] && ${cmd_echo} ${_json} | ${cmd_jq} -c '.data'


  # exit
  # clean up temp file
  [[ -f ${_tmp_file} ]] && ${cmd_rm} -f ${_tmp_file}


  return ${_exit_code}
}