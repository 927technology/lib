move.coriolis.create.transfer.schedules() {
  # edited
  # chris murray
  # 20251121

  # description
  # creates coriolis deployment schedule set in the ${_path}/${_profile}/transfers/${_name}.json 
  # writes output to ${_path}/${_profile}/executions/schedules/${_id}.json as json -c format

  # local variables
  local _json="{}"
  local _json_deployment="{}"
  local _json_transfer="{}"
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

  # transfer schedule with execution

  # create data directory
  ${cmd_mkdir} -p ${_path}/${_profile}/executions/schedules

  # create execution tmp file
  _tmp_file=$( ${cmd_mktemp} )

  # query names to schedlue for execution
  if    [[ ! -z ${_name} ]]; then
    move.list.transfers --name ${_name} --profile ${_profile} | ${cmd_jq} -c '. | select((( .[].move.coriolis.execution.date < '$( date.epoch )' ) and .[].move.coriolis.execution.enable == '${true}' ) and .[].coriolis.transfer.destination != null )' > ${_tmp_file}

  elif  [[ ! -z ${_filter} ]]; then
    move.list.transfers --filter ${_filter} --profile ${_profile}  | ${cmd_jq} -c '. | select((( .[].move.coriolis.execution.date < '$( date.epoch )' ) and .[].move.coriolis.execution.enable == '${true}' ) and .[].coriolis.transfer.destination != null )' > ${_tmp_file}

  fi

  # itterate transfers
  for transfer in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c '.[]' ); do
    move.coriolis.set.endpoint --name $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.coriolis.transfer.endpoint.destination' )

    # set transfer schedule
    if [[ ${_verbose} == ${true} ]]; then
      >&2 ${cmd_cat} << EOF.Transfer
${cmd_coriolis}
  transfer
  schedule 
  create 
  -H $( ${cmd_date} -d @$( ${cmd_echo} ${transfer} | ${cmd_jq} '.move.coriolis.execution.date' ) +'%H' )
  -M $( ${cmd_date} -d @$( ${cmd_echo} ${transfer} | ${cmd_jq} '.move.coriolis.execution.date' ) +'%M' )
  -m $( ${cmd_date} -d @$( ${cmd_echo} ${transfer} | ${cmd_jq} '.move.coriolis.execution.date' ) +'%m' ) 
  -d $( ${cmd_date} -d @$( ${cmd_echo} ${transfer} | ${cmd_jq} '.move.coriolis.execution.date' ) +'%d' )
  -f json 
  $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.[].ID' )

EOF.Transfer
    fi

    # execute api call for transfer schedule , capture output as json
    if [[ ${_dryrun} == ${false} ]]; then
      _json_transfer=$(
        ${cmd_coriolis}                                                                               \
          transfer                                                                                    \
          schedule                                                                                    \
          create                                                                                      \
          -H $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.execution.date' ) +'%H' )  \
          -M $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.execution.date' ) +'%M' )  \
          -m $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.execution.date' ) +'%m' )  \
          -d $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.execution.date' ) +'%d' )  \
          -f json                                                                                     \
          $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.ID' )                                           \
          2>/dev/null | ${cmd_jq} -c                                                                  \
      )
    fi

    shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] Schedule: Transfer"

    # validate json and write to file
    if  ( [[ ! -z ${_json_transfer}     ]] ||                                                       \
          [[ ${_json_transfer} != "{}"  ]]                                                          \
        ) &&                                                                                        \
        [[ $( ${cmd_echo} ${_json_transfer} | is_json ) == ${true} ]]; then
      ${cmd_echo} "${_json}" > ${_path}/${_profile}/transfers/schedules/$( ${cmd_echo} ${_json} | ${cmd_jq} -r '.ID' ).json
      ${cmd_ln} -fs $( ${cmd_echo} ${_json} | ${cmd_jq} -r '.ID' ).json ${_path}/${_profile}/transfers/schedules/${_name}

    else
      (( _error_count++ ))

    fi

  done

  # clean up tmp file
  [[ -f ${_tmp_file} ]] && ${cmd_rm} -f ${_tmp_file}


#   # transfer schedule with deployment

#   # create data directory
#   ${cmd_mkdir} -p ${_path}/${_profile}/deployments/schedules

#   # create execution tmp file
#   _tmp_file=$( ${cmd_mktemp} )

#   # query names to schedlue for deployment
#   if    [[ ! -z ${_name} ]]; then
#     move.list.transfers --name ${_name} --profile ${_profile} | ${cmd_jq} -c '. | select((( .[]move.coriolis.deployment.date < '$( date.epoch )' ) and .[].move.coriolis.deployment.enable == '${true}' ) and .[].coriolis.transfer.destination != null )' > ${_tmp_file}

#   elif  [[ ! -z ${_filter} ]]; then
#     move.list.transfers --filter ${_filter} --profile ${_profile}  | ${cmd_jq} -c '. | select((( .[]move.coriolis.deployment.date < '$( date.epoch )' ) and .[].move.coriolis.deployment.enable == '${true}' ) and .[].coriolis.transfer.destination != null )'  > ${_tmp_file}

#   fi

#   # itterate transfers
#   for transfer in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c '.[]' ); do
#     move.coriolis.set.endpoint --name $( move.list.transfers --name ${_name} | ${cmd_jq} -r '.coriolis.transfer.endpoint.destination' )

#     # set transfer schedule
#     if [[ ${_verbose} == ${true} ]]; then
#       >&2 ${cmd_cat} << EOF.Deployment
# ${cmd_coriolis}
#   transfer
#   schedule 
#   create 
#   -H $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.deployment.date' ) +'%H' )
#   -M $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.deployment.date' ) +'%M' ) 
#   -m $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.deployment.date' ) +'%m' ) 
#   -d $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.deployment.date' ) +'%d' )
#   -f json 
#   --shutdown-instance 
#   --auto-deploy 
#   $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.ID' )

# EOF.Deployment
#     fi

    # # execute api call for transfer schedule , capture output as json
    # if [[ ${_dryrun} == ${false} ]]; then
    #   _json_deployment=$(                                                                             \
    #     ${cmd_coriolis}                                                                               \
    #       transfer                                                                                    \
    #       schedule                                                                                    \
    #       create                                                                                      \
    #       -H $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.deployment.date' ) +'%H' )  \
    #       -M $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.deployment.date' ) +'%M' )  \
    #       -m $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.deployment.date' ) +'%m' )  \
    #       -d $( ${cmd_date} -d @$( move.list.transfers --name ${_name} | ${cmd_jq} '.move.coriolis.deployment.date' ) +'%d' )  \
    #       -f json                                                                                     \
    #       --shutdown-instance                                                                         \
    #       --auto-deploy                                                                               \
    #       $( ${cmd_echo} ${transfer} | ${cmd_jq} -r '.ID' )                                           \
    #       2>/dev/null | ${cmd_jq} -c                                                                  \
    #   )
    # fi

    # if  ( [[ ! -z ${_json_deployment}     ]] ||                                                     \
    #       [[ ${_json_deployment} != "{}"  ]]                                                        \
    #     ) &&                                                                                        \
    #     [[ $( ${cmd_echo} ${_json_deployment} | is_json ) == ${true} ]]; then
    #   _json=$(
    #     json.set                                                                                    \
    #       --json "${_json}"                                                                         \
    #       --key .data.deployment_schedules[$( ${cmd_echo} ${_json} | ${cmd_jq} 'try( .data.deployment_schedules | length )' )] \
    #       --value "${_json_deployment}"
    #   )

    # fi

  #   shell.log "${FUNCNAME}(${MOVE_PROFILE}) - [SUCCESS] Schedule: Deployment"

  #   # write schedules to transfer
  #   ${cmd_echo} "${_json}" | ${cmd_jq} -c > ${_path}/${MOVE_PROFILE}/transfers/$( ${cmd_echo} ${_json} | ${cmd_jq} -r '.vsphere.host.id' ).json

  # done

  # # clean up temp file
  # [[ -f ${_tmp_file} ]] && ${cmd_rm} -f ${_tmp_file}
  
  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}