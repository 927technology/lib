openssl.list.file() {
  # local variables
  local _algorithm=aes-256-cbc

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  local _file=
  local _key=
  local _verbose=${false}

  # parse arguments
  while [[ ${1} != "" ]]; do 
    case ${1} in
      -a | --algorithm )
        shift
        _algorithm="${1}"
      ;;
      -f | --file )
        shift
        _file="${1}"
      ;;
      -k | --key )
        shift
        _key="${1}"
      ;;
      -v | --verbose )
        _verbose=${true}
      ;;
     esac
    shift
  done

  # main
  if  [[ -f ${_file}  ]]  &&  \
      [[ -f ${_key}  ]]; then
    shell.log "${FUNCNAME} - [SSL]    Opening File"

    ${cmd_cat} ${_file} | ${cmd_openssl} enc -${_algorithm} -a -d -salt -pbkdf2 -kfile ${_key}
  else
    (( _error_count++ ))  

  fi

  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}
  return ${_exit_code}
}