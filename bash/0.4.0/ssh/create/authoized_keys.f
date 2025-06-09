ssh.create.authorized_keys() {
  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v

  # because IFS sucks
  IFS=$'\n'

  # argument variables
  local _user=
  local _user_home=
  local _verbose=${false}
  
  # local variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  
  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -u  | --user )
        shift
        _user=${1}
      ;;
      -uh  | --user-home )
        shift
        _user_home=${1}
      ;;
      -v  | --verbose )
        shift
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  if [[ -f /etc/ssh/sshd_config.d/${_user} ]]; then
    ${cmd_cat} << KEY_USER_EOF > /etc/ssh/sshd_config.d/${_user}
Match User ${_user}
  ChrootDirectory ${_user_home}
KEY_USER_EOF

    [[ ${?} != ${exitok} ]] && (( _error_count++ ))
  fi

  # set exit code
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  return ${_exit_code}
}