move.validate.transfers() {
  # local variables
  local _path=~move/move
  local _value=
  
  # argument variables
  local _filter=
  local _name=
  local _type=live_migration
  local _verbose=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local _tmp_file=$( ${cmd_mktemp} )

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -f | --filter )
        shift
        _filter="${1}"
      ;;
      -h | --host | -n | --name)
        shift
        _name="${1}"
      ;;
      -t | --type )
        shift
        _type=$( ${cmd_echo} "${1}" | lcase )
    
        case ${_type} in
          migration )
            _type=live_migration
          ;;
          replica | * )
            _type=replica
          ;;
        esac
      ;;
      -v | --verbose )
        shift
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  # create transfer temp file
  if    [[ ! -z ${_name} ]]; then
    move.list.transfers --host ${_name} | ${cmd_jq} -c > ${_tmp_file}

  elif  [[ ! -z ${_filter} ]]; then
    move.list.transfers --filter ${_filter} | ${cmd_jq} -c > ${_tmp_file}

  else
    move.list.transfers | ${cmd_jq} -c > ${_tmp_file}
  
  fi

  # itterate transfers
  for host in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c '.[]' ); do
    # coriolis transfer destination
    move.validate.key.coriolis_transfer_destination --json "${host}" || (( _error_count++ ))

    # move transfer/deployment schedule
    for schedule in transfer deployment; do
      move.validate.key.move_coriolis_schedule --json "${host}" --type ${schedule} || (( _error_count++ ))

    done

    # coriolis source/destination
    for direction in source destination; do
      move.validate.key.coriolis_transfer_endpoint --json "${host}" --direction ${direction} || (( _error_count++ ))

    done

    # coriolis network adapters
    move.validate.key.networkadapters --json "${host}" || (( _error_count++ ))

    # coriolis harddisks
    move.validate.key.harddisks --json "${host}" || (( _error_count++ ))

  done

  # exit
  [[ -f ${_tmp_file} ]] && ${cmd_rm} --force ${_tmp_file}
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}