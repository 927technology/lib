927.jenkins.cli() {
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
  local _job=
  local _verb=
  local _verbose=${false}
  
  # local variables
  local _err_count=0
  local _exit_code=${exit_warn}
  local _exit_string=

  # parse command arguments
  while [[ ${1} != "" ]]; do
    _verb=${1}
    shift

    case ${1} in
      -j  | --job )
        shift
        _job=${1}
      ;;
      -v  | --verbose )
        _verbose=${true}
      ;;
    esac
    shift
  done


  # main
  case ${_verb} in
    build )
      ${cmd_java} -jar /usr/local/bin/jenkins-cli.jar -s ${CICD_URL} -auth @${HOME}/secrets/cicd.pwd ${_verb} ${_job}
    ;;
  esac
}