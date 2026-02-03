function naemon.get.snmp() {
  # argument variables
  local _address=
  local _name=
  local _snmp_authentication_passphrase=
  local _snmp_authentication_protocol=
  local _snmp_community=
  local _snmp_level=
  local _snmp_path=/etc/naemon/snmp.d
  local _snmp_privacy_passphrase=
  local _snmp_privacy_protocol=
  local _snmp_username=
  local _snmp_version=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
   case ${1} in
    -a | --address )
      shift
      _address="${1}"
    ;;
    -n | --name )
      shift
      _name="${1}"
    ;;
    -sap | --snmp-authentication-passphrase )
      shift
      _snmp_authentication_passphrase="${1}"
    ;;
    -saP | --snmp-authentication-protocol )
      shift
      case $( ${cmd_echo} "${1}" | lcase ) in 
        md5 | sha | sha-224 | sha-256 | sha-384 | sha-512 )
          _snmp_authentication_protocol=$( ${cmd_echo} "${1}" | ucase )
        ;;
      esac
    ;;
    -sc | --snmp-community )
      shift
      _snmp_community="${1}"
    ;;
    -sl | --snmp-level )
      shift
      case $( ${cmd_echo} "${1}" | lcase ) in 
        noauthnopriv  ) _snmp_level=NoAuthNoPriv  ;;
        authnopriv    ) _snmp_level=AuthNoPriv    ;;
        authpriv      ) _snmp_level=AuthPriv      ;;
      esac
    ;;
    -sp | --snmp-path )
      shift
      _snmp_path="${1}"
    ;;
    -spp | --snmp-privacy-passphrase )
      shift
      _snmp_authentication_passphrase="${1}"
    ;;
    -spP | --snmp-privacy-protocol )
      shift
      case $( ${cmd_echo} "${1}" | lcase ) in 
        des | aes | aes-192 | ase-256 )
          _snmp_privacy_protocol=$( ${cmd_echo} "${1}" | ucase )
        ;;
      esac
    ;;
    -su | --snmp-username )
      shift
      _path="${1}"
    ;;
    -sv | --snmp-version )
      shift
      case $( ${cmd_echo} "${1}" | lcase ) in 
        1 | 2c | 3 )
          _snmp_version=$( ${cmd_echo} "${1}" | lcase )
        ;;
      esac
    ;;
    esac
    shift
  done

  # main
  # global validations
  if  [[ ! -z ${_address}       ]]  && \
      [[ ! -z ${_name}          ]]  && \
      [[ ! -z ${_snmp_path}     ]]  && \
      [[ ! -z ${_snmp_version}  ]]; then

    # create path
    if [[ ! -d ${_snmp_path} ]]; then
      ${cmd_mkdir} --parents ${_snmp_path} || (( _error_count++ ))

      case ${_snmp_version} in 
        1 | 2c )
          if  [[ ! -z ${_snmp_community} ]]; then
            ${cmd_snmpwalk}                                           \
              -c ${_snmp_community}                                   \
              -Onq                                                    \
              -v ${_snmp_version}                                     \
            > ${_snmp_path}/${_name}
          fi
        ;;
        3)
          if  [[ ! -z ${_snmp_authentication_passphrase}  ]] &&       \
              [[ ! -z ${_snmp_authentication_protocol}    ]] &&       \
              [[ ! -z ${_snmp_level}                      ]] &&       \
              [[ ! -z ${_snmp_privacy_passphrase}         ]] &&       \
              [[ ! -z ${_snmp_privacy_protocol}           ]]; then
            ${cmd_snmpwalk}                                           \
              -a ${_snmp_authentication_protocol}                     \
              -A ${_snmp_authentication_passphrase}                   \
              -l ${_snmp_level}                                       \
              -Onq                                                    \
              -v ${_snmp_version}                                     \
              -x ${_snmp_privacy_protocol}                            \
              -X ${_snmp_privacy_passphrase}                          \
            > ${_snmp_path}/${_name}
          fi
        ;;
      esac
    fi
  fi
}