vsphere.get.vms() {
  # local variables
  local _cmd=
  local _json=
  local _path=~move/vsphere
  local _tmp_file=$( ${cmd_mktemp} )

  # argument variables
  local _name=
  local _password=
  local _profile=
  local _search=
  local _type=
  local _user=
  local _vsphere=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local folder=
  local file=
  local vsphere=
  local vm=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -P  | --password )
        shift
        _password="${1}"
      ;;
      -p  | --profile )
        shift
        _profile="${1}"
      ;;
      -s  | --search )
        shift
        _search="${1}"
      ;;      
      -t  | --type )
        shift
        _type="${1}"
      ;;      
      -u  | --user )
        shift
        _user="${1}"
      ;;
      # -v  | --vsphere )
      #   shift
      #   _vsphere="${1}"
      # ;;
    esac
    shift
  done

  # main
  [[ -z ${_profile} ]] && _profile=${MOVE_PROFILE}

  ${cmd_mkdir} -p ${_path}/${_profile}/vms

  for vsphere in $( move.vsphere.list.active --output name ); do
    # zero out loop variables
    _name=
    _password=
    _user=
    _vsphere=

    move.vsphere.set.endpoint --name ${vsphere}

    _name=${VSPHERE_NAME}
    _password=${VSPHERE_PASSWORD}
    _user=${VSPHERE_USER}
    _vsphere=${VSPHERE_SERVER}
    
    shell.log "${FUNCNAME}(${_profile}) - [PARSING] vSphere: ${_vsphere}, This is a slow process, be patient"

    # check if vsphere server is available
    if [[ $( ${cmd_ping} -c 1 ${VSPHERE_SERVER} >/dev/null 2>&1; ${cmd_echo} ${?} ) == ${exit_ok} ]]; then
      
      # type and search are provided
      if  [[ ! -z ${_type} ]]     && \
          [[ ! -z ${_search} ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [FILTER] Type: ${_type}, Search: ${_search}"
        shell.log "${FUNCNAME}(${_profile}) - [WRITING] File: ${_tmp_file}"

        ${cmd_pwsh} -Command /usr/local/bin/powercli/get-vm.ps1 -name ${VSPHERE_NAME} -password ${VSPHERE_PASSWORD} -search ${_search} -type ${_type} -user ${VSPHERE_USER} -vsphere ${VSPHERE_SERVER} | ${cmd_grep} -v WARNING: > ${_tmp_file} 
        for vm in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c ); do
          vm=$(
            json.set \
              --json "${vm}" \
              --key ".coriolis.vsphere.endpoint" \
              --value "${vsphere}" \
          )

          shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${_name}, ID: $( ${cmd_echo} "${vm}" | ${cmd_jq} -r '.ID' ), VM: $( ${cmd_echo} "${vm}" | ${cmd_jq} -r '.Name' )"
          ${cmd_echo} "${vm}" | ${cmd_jq} -c > ${_path}/${_profile}/vms/"$( ${cmd_echo} "${vm}" | ${cmd_jq} -r '.ID' )".json


          # increment error
          [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
        done

      # all *not a good idea
      elif  [[ ${_type} == "all" ]]; then
        shell.log "${FUNCNAME}(${_profile}) - [WRITING] File: ${_tmp_file}"

        ${cmd_pwsh} -Command /usr/local/bin/powercli/get-vm.ps1 -name ${_name} -password ${_password} -user ${_user} -vsphere ${_vsphere} | ${cmd_jq} -c > ${_tmp_file}

        # for vm in $( ${cmd_pwsh} -Command /usr/local/bin/powercli/get-vm.ps1 -name ${_name} -password ${_password} -user ${_user} -vsphere ${_vsphere} | ${cmd_jq} -c ); do
        for vm in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c ); do
          vm=$(
            json.set \
              --json "${vm}" \
              --key ".coriolis.vsphere.endpoint" \
              --value "${vsphere}" \
          )

          shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${_name}, ID: $( ${cmd_echo} "${vm}" | ${cmd_jq} -r '.ID' ), VM: $( ${cmd_echo} "${vm}" | ${cmd_jq} -r '.Name' )"
          ${cmd_echo} "${vm}" | ${cmd_jq} > ${_path}/${_profile}/vms/"$( ${cmd_echo} "${vm}" | ${cmd_jq} -r '.ID' )".json


          # increment error
          [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
        done
      fi

    else
      shell.log "${FUNCNAME}(${_profile}) - [FAILURE] vSphere: ${VSPHERE_SERVER} is unavailable"
      (( _error_count++ ))
    fi
  done

  shell.log "${FUNCNAME}(${_profile}) - [ERROR COUNT] ${_error_count}"


  # cleanup
  if [[ -f ${_tmp_file} ]]; then
    shell.log "${FUNCNAME}(${_profile}) - [DELETING] File: ${_tmp_file}"
    
    ${cmd_rm} -f ${_tmp_file}
  fi

  # set exit code
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  shell.log "${FUNCNAME}(${_profile}) - [COMPLETE]"
  return ${_exit_code}
}