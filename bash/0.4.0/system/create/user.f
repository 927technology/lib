system.create.user() {
  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v

  # argument variables
  local _user=
  local _user_home=
  local _user_shell=
  local _user_uid=
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
      -us  | --user-shell )
        shift
        _user_shell=${1}
      ;;
      -uu  | --user-uid )
        shift
        _user_uid=${1}
      ;;
      -v  | --verbose )
        shift
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  if [[ $( ${cmd_getent} passwd ${_user} | ${cmd_grep} -c ${_user} ) == 0 ]]; then
    if    [[ ! -z ${_user_home}   ]] &&                               \
          [[ ! -z ${_user_shell}  ]] &&                               \
          [[ ! -z ${_user_uid}    ]]; then
  
      # create user
      ${cmd_useradd}                                                  \
        --create-home                                                 \
        --home-dir      ${_user_home}                                 \
        --shell         ${_user_shell}                                \
        --uid           ${_user_uid}                                  \
        ${_user}

    elif  [[ ! -z ${_user_home}   ]] &&                               \
          [[ ! -z ${_user_shell}  ]]; then

      # create user
      ${cmd_useradd}                                                  \
        --create-home                                                 \
        --home-dir      ${_user_home}                                 \
        --shell         ${_user_shell}                                \
        ${_user}

    elif  [[ ! -z ${_user_home}   ]]; then

      # create user
      ${cmd_useradd}                                                  \
        --create-home                                                 \
        --home-dir      ${_user_home}                                 \
        ${_user}

    elif  [[ ! -z ${_user_shell}  ]]; then

      # create user
      ${cmd_useradd}                                                  \
        --create-home                                                 \
        --shell         ${_user_shell}                                \
        ${_user}

    else

      # create user
      ${cmd_useradd}                                                  \
        --create-home                                                 \
        ${_user}
    fi

    [[ ${?} != ${exitok} ]] && (( _error_count++ ))
  fi

  # set exit code
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # exit
  return ${_exit_code}
}