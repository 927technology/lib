move.coriolis.execute.transfer() {
  # edited
  # chris murray
  # 20260226

  # description
  # 

  # local variables
  local _json="{}"
  local _json_output="{}"
  local _path=~move/move
  local _tmp_file=

  # argument variables
  local _dryrun=${false}
  local _filter=
  local _force=${false}
  local _name=
  local _profile=
  local _verbose=${false}

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

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
      -F | --force )
        _force=${true}
      ;;
      -h | --host | -n | --name )
        shift
        _name=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -p  | --profile )
        shift
        _profile=$( ${cmd_echo} "${1}" | lcase )
      ;;
      -v | --verbose )
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  # set credentials
  [[ -z ${_profile} ]] && return ${exit_crit}

  # create temp file
  _tmp_file=$( ${cmd_mktemp} )
  shell.log "${FUNCNAME}(${_profile}) - [CREATE] File:${_tmp_file}"

  if    [[ ! -z ${_name} ]]; then
    move.list.transfers --name ${_name} --profile ${_profile} > ${_tmp_file}

  elif  [[ ! -z ${_filter} ]]; then
    move.list.transfers --filter ${_filter} --profile ${_profile}  > ${_tmp_file}

  fi

  # itterate transfers
  for transfer in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c '.[]' ); do
    if [[ ${_dryrun} == ${false} ]]; then
      # move.list.transfers.created --latest --name 
      
      # set endpoint
      move.coriolis.set.endpoint                              \
        --name $(                                             \
          ${cmd_echo} ${transfer} | ${cmd_jq} -r '.coriolis.transfer.endpoint.destination' \
        )                                                     \
        --profile ${_profile}               

      _json_output=$(                                           \
        ${cmd_coriolis}                                         \
          transfer                                              \
          execute                                               \
          -f json                                               \
          $(                                                    \
            move.list.transfers.created                         \
              --latest                                          \
              --name $(                                         \
                ${cmd_echo} ${transfer} | ${cmd_jq} -r '.name'  \
              )                                                 \
              --output id                                       \
              --profile ${_profile}                             \
          ) | ${cmd_jq} -c                                      \
      )

    else
      if [[ ${_verbose} == ${true} ]]; then
        >&2 ${cmd_cat} << EOF.Transfer 
${cmd_coriolis}
  transfer
  execute
  -f json
  $(                                                            \
    move.list.transfers.created                                 \
      --latest                                                  \
      --name $(                                                 \
        ${cmd_echo} ${transfer} | ${cmd_jq} -r '.name'          \
      )                                                         \
      --output id                                               \
      --profile ${_profile}                                     \
  )                      
EOF.Transfer
      fi
    fi

    if  [[ ${?} == ${exit_ok} ]] && \
        [[ ${_dryrun} == ${false} ]]; then
      shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] ID:$(  ${cmd_echo} ${_json_output} | ${cmd_jq} -r '.id' ), VM: ${_name}"
  
      # write transfer output to vm json
      if  ( [[ ! -z ${_json_output}     ]] ||                                                       \
            [[ ${_json_output} != "{}"  ]]                                                          \
          ) &&                                                                                      \

        [[ $( ${cmd_echo} "${_json_output}" | is_json ) == ${true} ]]; then

        # create output directory
        [[ ! -d ${_path}/${_profile}/transfers/execute/${_name} ]] && ${cmd_mkdir} --parents ${_path}/${_profile}/transfers/execute/${_name}

        # output json
        ${cmd_echo} ${_json_output} > ${_path}/${_profile}/transfers/execute/${_name}/$(  ${cmd_echo} ${_json_output} | ${cmd_jq} -r '.id' ).json
      fi

    else
      shell.log "${FUNCNAME}(${_profile}) - [DRY RUN] ID: none, VM: ${_name}"

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