move.create.translations() {
  # local variables
  local _json="{}"
  local _path=~move/move

  # argument variables
  local _profile=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in     
      -p | --profile )
        shift
        _profile="${1}"
      ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}
  [[ -z ${_profile} ]] && return ${exit_crit}

  if [[ -f /etc/move/${_profile}/translation.csv ]]; then

    # create cache directory
    if [[ ! -d ${_path}/${_profile}/translations ]]; then
      shell.log "${FUNCNAME}(${_profile}) - [CREATE] Path: ${_path}/${_profile}/translations"
      ${cmd_mkdir} --parents ${_path}/${_profile}/translations

    else
      for file in ${_path}/${_profile}/translations/*.json; do
        ${cmd_rm} -f ${file}
        shell.log "${FUNCNAME}(${_profile}) - [PURGE] VM: $( ${cmd_echo} ${file} | ${cmd_awk} -F"/" '{print $NF}' | ${cmd_awk} -F"." '{print $1}' )"

      done
    fi

    ${cmd_grep} -v ^# /etc/move/${_profile}/translation.csv | \
      while IFS=, read -r                 \
        host                              \
        olvm_cluster                      \
        olvm_data_center                  \
        olvm_storage_domain_minion        \
        olvm_storage_domain               \
        olvm_vlan                         \
        coriolis_deployment_date          \
        coriolis_transfer_date            \
        notes
        do

        shell.log "${FUNCNAME}(${_profile}) - [CREATE] VM: ${host}"

        _json=$( json.set --json ${_json} --key .name                        --value ${host}                       || (( _error_count++ )) )
        _json=$( json.set --json ${_json} --key .olvm.cluster                --value ${olvm_cluster}               || (( _error_count++ )) )
        _json=$( json.set --json ${_json} --key .olvm.data_center            --value ${olvm_data_center}           || (( _error_count++ )) )
        _json=$( json.set --json ${_json} --key .olvm.storage_domain.host    --value ${olvm_storage_domain}        || (( _error_count++ )) )
        _json=$( json.set --json ${_json} --key .olvm.storage_domain.minion  --value ${olvm_storage_domain_minion} || (( _error_count++ )) )
        _json=$( json.set --json ${_json} --key .olvm.vlan                   --value ${olvm_vlan}                  || (( _error_count++ )) )
        _json=$( json.set --json ${_json} --key .coriolis.date.deployment    --value ${coriolis_deployment_date}   || (( _error_count++ )) )
        _json=$( json.set --json ${_json} --key .coriolis.date.transfer      --value ${coriolis_transfer_date}     || (( _error_count++ )) )

        ${cmd_echo} ${_json} > ${_path}/${_profile}/translations/${host}.json

        # zero json
        _json="{}"
      done 
  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok} 

  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"
  
  return ${_exit_code}
}