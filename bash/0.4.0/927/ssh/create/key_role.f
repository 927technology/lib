927.ssh.create.key_role() {
  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # ssh/create/chroot_config.f
  # system/create/user.f

  # because IFS sucks
  IFS=$'\n'

  # argument variables
  local _key_json="{}"
  local _verbose=${false}
  
  # local variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _json="{}"
  local _key_count=0
  local _key_priv=
  local _key_pub=
  local _key_role=
  local _key_user=
  local _key_user_home=
  local _key_user_gid=
  local _key_user_uid=
  local _key_json="{}"

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -kj  | --key-json )
        shift
        _key_json=${1}
      ;;
      -v  | --verbose )
        shift
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  # determine if key_role is in effect and there are keys
  if  [[ $( ${cmd_echo} ${_key_json} | ${cmd_jq} 'try(.keys | length)' ) > 0 ]]; then
    for key_set in $( ${cmd_echo} ${_key_json} | ${cmd_jq} -c '.keys[]' ); do
      # clear loop varibles
      _key_role=
      _key_priv=
      _key_pub=
      _key_json="{}"
      
      # set root variables
      _key_role=$( ${cmd_echo} ${key_set} | ${cmd_jq} -r 'try( .role )  | if( . == null ) then "" else . end' )
      _key_priv=$( ${cmd_echo} ${key_set} | ${cmd_jq} -r 'try( .priv )  | if( . == null ) then "" else . end' )
      _key_pub=$( ${cmd_echo} ${key_set}  | ${cmd_jq} -r 'try( .pub )   | if( . == null ) then "" else . end' )

      # does user exist on this system
        case ${_key_role} in
          cicd )
            _key_user=nts_cicd
            _key_user_home=/ops/cicd
            _key_user_uid=1605
          ;;
          job )
            _key_user=nts_job
            _key_user_home=/ops/job
            _key_user_uid=1603
          ;;
          management )
            _key_user=nts_ms
            _key_user_home=/ops/management
            _key_user_uid=1601
          ;;
          web )
            _key_user=nts_web
            _key_user_home=/ops/web
            _key_user_uid=1602
          ;;
          worker )
            _key_user=nts_worker
            _key_user_home=/ops/worker
            _key_user_uid=1604
          ;;
        esac

        _key_json=$( ${cmd_echo} ${_key_json} | ${cmd_jq} -c '.role       |=.+ "'"${_key_role}"'"' )
        _key_json=$( ${cmd_echo} ${_key_json} | ${cmd_jq} -c '.user.name  |=.+ "'"${_key_user}"'"' )
        _key_json=$( ${cmd_echo} ${_key_json} | ${cmd_jq} -c '.user.home  |=.+ "'"${_key_user_home}"'"' )
        _key_json=$( ${cmd_echo} ${_key_json} | ${cmd_jq} -c '.user.uid   |=.+ '${_key_user_uid} )
        
        if [[ ${_verbose} == ${true} ]]; then
          ${cmd_echo} ${_key_json} >&2
        fi


        # create user if not present
        if [[ $( ${cmd_getent} passwd ${_key_user} | ${cmd_grep} -c ${_key_user} ) == 0 ]]; then
          
          # create key_user home root path
          if [[ ! -d /ops ]]; then
            ${cmd_mkdir} -p /ops --mode=00755
            ${cmd_chown} root:root /ops
          fi

          # create key_user
          system.create.user                                          \
            --user-home     ${_key_user_home}                         \
            --user-shell    /bin/bash                                 \
            --user-uid      ${_key_user_uid}                          \
            --user          ${_key_user}
        fi

        # create user sshd chroot config file if not present
        if [[ -f /etc/ssh/sshd_config.d/${_key_user} ]]; then
          ssh.create.chroot_config                                    \
            --user          ${_key_user}                              \
            --user-home     ${_key_user_home}
        fi

        # create ${HOME}/.ssh
        if [[ ! -d ${_key_user_home}/.ssh ]]; then
          ${cmd_mkdir} --mode=00700 ${_key_user_home}/.ssh
          ${cmd_chown} ${_key_user}:${_key_user} ${_key_user_home}/.ssh
        fi


        # create ${HOME}/.ssh/authorized_keys
        if [[ ! -f ${_key_user_home}/.ssh/authorized_keys ]]; then
          ${cmd_touch} ${_key_user_home}/.ssh/authorized_keys
          ${cmd_chown} ${_key_user}:${_key_user} ${_key_user_home}/.ssh/authorized_keys
          ${cmd_chmod} 600 ${_key_user_home}/.ssh/authorized_keys
        fi 

        # create authorized keys
        if [[ ! -z ${_key_pub} ]]; then

          # add pub key if not in ${HOME}/.ssh/authorized_keys
          # if [[ ${cmd_grep} -c ${_key_pub} ${_key_user_home}/.ssh/authorized_keys == 0 ]]; then
            ${cmd_echo} ${_key_pub} >> ${_key_user_home}/.ssh/authorized_keys
          # fi
        fi

        # create private keys
        if [[ ! -z ${_key_priv} ]]; then

          # add private key if not in ${HOME}/.ssh
          if [[ ! -f ${_key_user_home}/.ssh/${_key_user}  ]]; then
            ${cmd_echo} ${_key_priv} > ${_key_user_home}/.ssh/${_key_user}
          fi
        fi

      # add _key_json object to json output
      _json=$( ${cmd_echo} ${_json} | ${cmd_jq} -c '.keys['${_key_count}']  |=.+ '"${_key_json}" )
      (( _key_count++ ))

    done
  fi
  # set exit code
  [[ ${_error_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  # set exit_string
  _exit_string=$( ${cmd_echo} ${_json} | ${cmd_jq} -c )


  # exit
  ${cmd_echo} ${_exit_string}

  return ${_exit_code}
}