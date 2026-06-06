libnss.wrapper() {
  # edited
  # chris murray
  # 20260311

  # description
  # 

  # local variables
  local _tmp_file=$( ${cmd_mktemp} )

  # argument variables
  local _name=
  local _ip=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -i  | --ip )
        shift
        _ip="${1}"
      ;;
      -n  | --name )
        shift
        _name=$( ${cmd_echo} "${1}" | lcase )
      ;;

    esac
    shift
  done

  # main
  shell.log "${FUNCNAME}(${_profile}) - [CREATING] File:  ${_tmp_file}"

  ${cmd_echo} ${_ip} ${_name} > ${_tmp_file}
  export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
  LD_PRELOAD=/usr/lib64/libnss_wrapper.so
  export NSS_WRAPPER_HOSTS=${_tmp_file}
  NSS_WRAPPER_HOSTS=${_tmp_file}
  shell.ping --name ${_name} || (( _error_count++ ))

  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  return ${_exit_code}
}