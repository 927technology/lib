secretservice.create.secret () {
  # description
  # creates oci cli configuration by using the configuration provided
  # accepts 2 arguments -
  ## -p/--path which is the full path to the root folder to place .oci/config file
  ## this is typically the path to a home folder of the service account

  # dependancies
  # variables/cmd/<distro>.v
  # variables/bools.v
  # variables/exits.v

  # argument variables
  local _length=256
  local _key=
  local _verbose=${false}
  
  # local variables
  local _err_count=0
  local _exit_code=${exit_warn}
  local _exit_string=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -l  | --length )
        shift
        _length=${1}
      ;;
    esac
    shift
  done

  # main
  _key=$( ${cmd_head} -c ${_length} /dev/urandom | ${cmd_base64} | ${cmd_tr} -dc 'a-zA-Z0-9' )
  [[ ${?} != ${exit_ok} ]] && (( _err_count++ ))

  # exit status
  [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit string
  [[ ${_err_count} == 0 ]] && _exit_string=${_key}

  # exit
  ${cmd_echo} ${_exit_string}

  #return
  return ${_exit_code}
}