927.secretservice.get.cicdauth () {
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
  local _cicd_user=
  local _cicd_pass=
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

  if [[ ! -z ${_group} ]] && [[ ! -z ${_owner} ]] && [[ -d ${_path} ]] && [[ ! -z ${_secrets_provider} ]] ; then
    case ${_secrets_provider} in
      bitwarden )
        # get config from secrets provider
        _cicd_pass=$( ${cmd_bws} secret list | ${cmd_jq} -r '.[] | select(.key == "cicd_pass").value' )
        _cicd_user=$( ${cmd_bws} secret list | ${cmd_jq} -r '.[] | select(.key == "cicd_user").value' )
      ;;
    esac

    # ensure user name and password are not blank
    if [[ ! -z ${_cicd_pass} ]] && [[ ! -z ${_cicd_user} ]]; then

      # create folder, set owner, group and mode
      [[ ! -d ${_path}/secrets ]] && ${cmd_mkdir} ${_path}/secrets
      ${cmd_chown} ${_owner}:${_group} ${_path}/secrets
      ${cmd_chmod} 550 ${_path}/secrets

      # write password file
      ${cmd_echo} ${_cicd_user}:${_cicd_pass} > ${_path}/secrets/cicd.pwd

      # set owner, group, and mode
      ${cmd_chown} ${_owner}:${_group} ${_path}/secrets/cicd.pwd
      ${cmd_chmod} 600 ${_path}/secrets/cicd.pwd
    else
      # oopsie
      (( _err_count++ ))
    fi
  else
    # oopsie
    (( _err_count++ ))
  fi


  # exit status
  [[ ${_err_count} > 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  #return
  return ${_exit_code}
}