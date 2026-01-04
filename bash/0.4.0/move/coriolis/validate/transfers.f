move.coriolis.validate.transfers() {
  # local variables
  local _tmp_file=$( ${cmd_mktemp} )

  # argument variables
  local _filter=
  local _name=
  local _output=

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
    esac
    shift
  done

  # main
  # create transfer temp file
  if    [[ ! -z ${_name} ]]; then
    move.list.transfers.active --name ${_name} > ${_tmp_file}

  elif  [[ ! -z ${_filter} ]]; then
    move.list.transfers.active --filter ${_filter} > ${_tmp_file}

  else
    move.list.transfers.active | ${cmd_jq} -c  > ${_tmp_file}
  
  fi

  # itterate hosts
  for host in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c '.[]' ); do
    # find corrisponding coriolis transfer
    case $( move.coriolis.list.transfers | ${cmd_jq} '.[] | select( .ID == "'"$( ${cmd_echo} ${host} | ${cmd_jq} -r '.transfers.id' )"'" )' | ${cmd_jq} -s '. | length' ) in
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

    if [[ ! -z ${_output} ]]; then
      case ${_output} in
        id        ) ${cmd_echo} ${host} | ${cmd_jq} -r '.transfers.id'                                             ;;
        name      ) ${cmd_echo} ${host} | ${cmd_jq} -r '.name'                                           ;;
      esac
    fi

  done

  # exit
  ${cmd_rm} -f ${_tmp_file}

  return ${_exit_code}
}