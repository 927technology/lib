927.secretservice.get.jobserver () {
  # description
  # creates oci cli configuration by using the configuration provided
  # accepts 2 arguments -
  ## -p/--path which is the full path to the root folder to place .oci/config file
  ## this is typically the path to a home folder of the service account

  # dependancies
  # 927.bools.v
  # 927/cmd_el.v
  # 927/nagios.v
  # json/validate.f

  # argument variables
  local _jobserver_pass=
  local _group=
  local _owner=
  local _path=
  local _secrets_provider=
  local _verbose=${false}
  
  # local variables
  local _err_count=0
  local _exit_code=${exit_warn}
  local _exit_string=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -g  | --group )
        shift
        _group=${1}
      ;;
      -o  | --owner )
        shift
        _owner=${1}
      ;;
      -p  | --path )
        shift
        _path=${1}
      ;;
      -sp | --secrets-provider )
        shift
        _secrets_provider=${1}
      ;;
      -v  | --verbose )
        _verbose=${true}
      ;;
    esac
    shift
  done

  # main
  [[ ${_verbose} == ${true} ]] && ${cmd_echo} group:${_group} owner:${_owner} path:${_path} secret:${_secrets_provider}

  if [[ ! -z ${_group} ]] && [[ ! -z ${_owner} ]] && [[ -d ${_path} ]] && [[ ! -z ${_secrets_provider} ]]; then
    case ${_secrets_provider} in
      bitwarden )
        # get config from secrets provider
        _jobserver_pass=$( ${cmd_bws} secret list | ${cmd_jq} -r '.[] | select(.key == "jobserver_pass").value' )
      ;;
    esac

    if [[ ! -f ${_path}/secrets/jobserver.pwd ]] || \
       [[ $( ${cmd_cat} ${_path}/secrets/jobserver.pwd | ${cmd_sha256sum} ) != $( ${cmd_echo} ${_jobserver_pass} | ${cmd_sha256sum} ) ]]; then
      # ensure user name and password are not blank
      if [[ ! -z ${_jobserver_pass} ]]; then

        # create folder, set owner, group and mode
        [[ ! -d ${_path}/secrets ]] && ${cmd_mkdir} ${_path}/secrets
        ${cmd_chown} ${_owner}:${_group} ${_path}/secrets
        ${cmd_chmod} 770 ${_path}/secrets

        # write password file
        ${cmd_echo} ${_jobserver_pass} > ${_path}/secrets/jobserver.pwd

        # set owner, group, and mode
        ${cmd_chown} ${_owner}:${_group} ${_path}/secrets/jobserver.pwd
        ${cmd_chmod} 600 ${_path}/secrets/jobserver.pwd

        _exit_code=${exit_warn}
      else
        # oopsie
        (( _err_count++ ))
      fi
    else
      # oopsie
      (( _err_count++ ))
    fi
  else
    _exit_code=${exit_ok}
  fi

  # exit status
  [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit}
  _exit_string=${_exit_code}

  # exit string
  ${cmd_echo} ${_exit_string}

  #return
  return ${_exit_code}
}