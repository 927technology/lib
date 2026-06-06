vsphere.get.networks() {
  # local variables
  local _path=~move/vsphere
  local _tmp_file=$( ${cmd_mktemp} )

  # argument variables
  local _name=
  local _password=
  local _profile=
  local _user=
  local _vsphere=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=
  local vsphere=
  local network=

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
  [[ -z ${_profile} ]] && { shell.log "${FUNCNAME}(${_profile}) - [PROFILE] Profile is not set.   Set profile move.set.profile --name <profile name>"; return ${exit_crit}; }

  ${cmd_mkdir} -p ${_path}/${_profile}/networks

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
      shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] vSphere: ${VSPHERE_SERVER} is available"
      shell.log "${FUNCNAME}(${_profile}) - [WRITING] File: ${_tmp_file}"

      ${cmd_pwsh}                                         \
        -Command /usr/local/bin/powercli/get-networks.ps1 \
        -name ${VSPHERE_NAME}                             \
        -password ${VSPHERE_PASSWORD}                     \
        -user ${VSPHERE_USER}                             \
        -vsphere ${VSPHERE_SERVER} | ${cmd_grep} -v WARNING: > ${_tmp_file}

      for network in $( ${cmd_cat} ${_tmp_file} | ${cmd_jq} -c ); do
        shell.log "${FUNCNAME}(${_profile}) - [SUCCESS] End Point: ${_name}, Name: $( ${cmd_echo} "${network}" | ${cmd_jq} -r '.name' ), VLAN: $( ${cmd_echo} "${network}" | ${cmd_jq} -r '.vlan_id' )"
        
        # output json
        ${cmd_echo} "${network}" | ${cmd_jq} -c > ${_path}/${_profile}/networks/"$( ${cmd_echo} "${network}" | ${cmd_jq} -r '.name' )".json

        # increment error
        [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))
      done

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