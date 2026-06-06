move.coriolis.create.transfers.schedule() {
  # edited
  # chris murray
  # 20260129

  # description
  # creates coriolis transfer schedule set in the ${_path}/${_profile}/transfers/${_name}.json 
  # writes output to ${_path}/${_profile}/transfers/schedules/${_id}.json as json -c format

  # local variables
  local _json="{}"
  local _json_transfer="{}"
  local _json_schedule="{}"
  local _path=~move/move
  local _tmp_file=

  # argument variables
  local _dryrun=${false}
  local _filter=
  local _name=
  local _profile=
  local _verbose=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local host=
  local transfer=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -dr | --dry-run )
        _dryrun=${true}
      ;;
      -f | --filter )
        shift
        _filter="${1}"
      ;;
      -h | --host | -n | --name )
        shift
        _name="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
      -v | --verbose )
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  # set credentials
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  [[ -z ${_profile} ]] && return ${exit_crit}

  # create temp file
  _tmp_file=$( ${cmd_mktemp} )
  shell.log "${FUNCNAME}(${_profile}) - [CREATE] File:${_tmp_file}"

  # create data directory
  shell.log "${FUNCNAME}(${_profile}) - [CREATE] ${_path}/${_profile}/transfers/schedules"

  ${cmd_mkdir} -p ${_path}/${_profile}/transfers/schedules

  # query names to schedlue for transfer
  if    [[ ! -z ${_name} ]]; then
    move.list.transfers --name ${_name} --profile ${_profile} | ${cmd_jq} -c '.[] | select(( .move.coriolis.transfer.enable == '${true}' ) and .move.coriolis.transfer.date != null )' > ${_tmp_file}

  elif  [[ ! -z ${_filter} ]]; then
    move.list.transfers --filter ${_filter} --profile ${_profile}  | ${cmd_jq} -c '.[] | select(( .move.coriolis.transfer.enable == '${true}' ) and .move.coriolis.transfer.date != null )' > ${_tmp_file}

  fi

  # itterate transfers
  for transfer in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c ); do
    move.coriolis.set.endpoint --name $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.coriolis.transfer.endpoint.destination' )

    # set transfer schedule
    if [[ ${_verbose} == ${true} ]]; then
      >&2 ${cmd_cat} << EOF.Transfer
${cmd_coriolis}
  transfer
  schedule 
  create 
  -H $( ${cmd_date} -d @$( ${cmd_echo} ${transfer} | ${cmd_jq} '.move.coriolis.transfer.date' ) +'%H' )
  -M $( ${cmd_date} -d @$( ${cmd_echo} ${transfer} | ${cmd_jq} '.move.coriolis.transfer.date' ) +'%M' )
  -m $( ${cmd_date} -d @$( ${cmd_echo} ${transfer} | ${cmd_jq} '.move.coriolis.transfer.date' ) +'%m' ) 
  -d $( ${cmd_date} -d @$( ${cmd_echo} ${transfer} | ${cmd_jq} '.move.coriolis.transfer.date' ) +'%d' )
  -f json 
  $( move.list.transfers.created --name $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.name' ) --output id )

EOF.Transfer
    fi
    # execute api call for transfer schedule , capture output as json
    if [[ ${_dryrun} == ${false} ]]; then
      _json_schedule=$(
        ${cmd_coriolis}                                                                               \
          transfer                                                                                    \
          schedule                                                                                    \
          create                                                                                      \
          -H $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.[-1].move.coriolis.transfer.date' ) +'%H' )  \
          -M $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.[-1].move.coriolis.transfer.date' ) +'%M' )  \
          -m $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.[-1].move.coriolis.transfer.date' ) +'%m' )  \
          -d $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.[-1].move.coriolis.transfer.date' ) +'%d' )  \
          -f json                                                                                     \
          $( move.list.transfers.created --name $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.name' ) --output id ) \
          2>/dev/null | ${cmd_jq} -c                                                                  \
      )
    fi

    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] VM: $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.name' ), Schedule ID: $( ${cmd_echo} ${_json_schedule} | ${cmd_jq} -r '.id' ), Transfer ID: $( move.list.transfers.created --name $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.name' ) --output id )"

    # validate json and write to file
    if  ( [[ ! -z ${_json_schedule}     ]] ||                                                       \
          [[ ${_json_schedule} != "{}"  ]]                                                          \
        ) &&                                                                                        \
        [[ $( ${cmd_echo} ${_json_schedule} | is_json ) == ${true} ]]; then

      [[ ! -d ${_path}/${_profile}/transfers/schedules/$( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.name' )/transfers ]] && ${cmd_mkdir} --parents ${_path}/${_profile}/transfers/schedules/$( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.name' )/transfers
      ${cmd_echo} "${_json_schedule}" > ${_path}/${_profile}/transfers/schedules/$( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.name' )/transfers/$( ${cmd_echo} ${_json_schedule} | ${cmd_jq} -r '.id' ).json

    else
      (( _error_count++ ))

    fi
  done

  # clean up tmp file
  shell.log "${FUNCNAME}(${_profile}) - [DELETING] File:${_tmp_file}"
  [[ -f ${_tmp_file} ]] && ${cmd_rm} -f ${_tmp_file}
  
  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}