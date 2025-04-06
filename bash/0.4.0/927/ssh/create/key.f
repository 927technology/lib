927.ssh.create.key() {
  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v

  # argument variables
  local _key_length=2048
  local _key_path=${HOME}/.ssh
  local _key_role=none
  local _key_type=rsa
  local _verbose=${false}
  
  # local variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _json="{}"
  local _key_priv=
  local _key_pub=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -kl  | --key-length )
        shift
        _key_length=${1}
      ;;
      -kp  | --key-path )
        shift
        _key_path=${1}
      ;;
      -kr | --key-role )
        shift
        _key_role=${1}
      ;;
      -kt  | --key-type )
        shift
        _key_type=${1}
      ;;
      -v  | --verbose )
        shift
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  # create key path if not exist
  [[ ! -d ${_key_path} ]] && ${cmd_mkdir} ${_key_path}

  # delete key if exists
  if  [[ -f ${_key_path}/temp_key ]] || \
      [[ -f ${_key_path}/temp_key.pub ]]; then
      echo deleting existing keyfrom ${_key_path}
    ${cmd_rm} -f ${_key_path}/temp_key*
  fi

  # generate key and add to variables
  ${cmd_ssh_keygen} -q -t ${_key_type} -b ${_key_length} -N '' -f ${_key_path}/temp_key
  _key_priv=$( cat ${_key_path}/temp_key )
  _key_pub=$( cat ${_key_path}/temp_key.pub | ${cmd_awk} '{print $1 " " $2}' )

  # delete key 
  ${cmd_rm} -f ${_key_path}/temp_key*

  # add key to json
  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.key[0].priv  |=.+ "'"${_key_priv}"'"' )
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))

  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.key[0].pub   |=.+ "'"${_key_pub}"'"' )
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))

  _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.key[0].role   |=.+ "'"${_key_role}"'"' )
  [[ ${?} != ${exit_ok} ]] && (( _error_count++ ))

  # set exit code
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  ${cmd_echo} ${_json}

  return ${_exit_code}
}