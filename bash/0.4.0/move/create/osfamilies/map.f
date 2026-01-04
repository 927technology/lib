move.create.osfamilies.map() {
  # local variables
  local _arch=
  local _arch_suffix=
  local _json=
  local _os_release=
  local _path=~move/move
  local _path_vsphere=~move/vsphere

  # argument variables
  # none

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  # none

  # main
  ${cmd_mkdir} -p ${_path}/osfamilies

  for osfamily in $( ${cmd_cat} ${_path_vsphere}/vms/*.json | ${cmd_jq} '.GuestOS' | ${cmd_jq} -sr '. | unique | sort | .[]' ); do
    # zero out loop variables
    _arch=
    _arch_suffix=
    _json=
    _os_release=

    # set vsphere name
    _json=$( json.set --json ${_json} --key .vsphere.name --value ${osfamily} )
    
    # set architecture
    case $( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $NF}' ) in
      "(32-bit)" )
        _arch=x86
        _arch_suffix=
      ;;
      "(64-bit)" )
        _arch=x86_64
        _arch_suffix=x64
      ;;
    esac
    
    _json=$( json.set --json ${_json} --key .os.arch --value ${_arch} )

    # set distro specific os values
    if  [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic ^CentOS ) > 0 ]]; then
      case $( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $2}' ) in 
        "4/5/6/7" )
          _os_release=7
        ;;
        "4/5/6" )
          _os_release=6
        ;;
        "4/5" )
          _os_release=5
        ;;
        * )
          _os_release=$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $2}' ) 
        ;;
      esac

      _json=$( json.set --json ${_json} --key .os.distro  --value "centos" )
      _json=$( json.set --json ${_json} --key .os.family  --value "linux" )
      _json=$( json.set --json ${_json} --key .os.version --value "$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $2}' )" )
      _json=$( json.set --json ${_json} --key .olvm.name  --value "rhel_${_os_release}${_arch_suffix}" )
    
    elif  [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic ^CoreOS ) > 0 ]]; then
      _json=$( json.set --json ${_json} --key .olvm.name  --value "rhcos_${_arch_suffix}" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "centos" )
      _json=$( json.set --json ${_json} --key .os.family  --value "linux" )
      _json=$( json.set --json ${_json} --key .os.version --value "$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $2}' )" )

    elif  [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic ^Debian ) > 0 ]]; then
      _os_release=$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $3}' ) 

      _json=$( json.set --json ${_json} --key .olvm.name  --value "debian_${_os_release}" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "debian" )
      _json=$( json.set --json ${_json} --key .os.family  --value "linux" )
      _json=$( json.set --json ${_json} --key .os.version --value "$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $3}' )" )
    
    elif [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic ^Microsoft\ Windows\ Server ) > 0 ]]; then
      _os_release=$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $4}' ) 
      
      _json=$( json.set --json ${_json} --key .olvm.name  --value "windows_${_os_release}${_arch_suffix}" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "windows" )
      _json=$( json.set --json ${_json} --key .os.family  --value "windows" )
      _json=$( json.set --json ${_json} --key .os.version --value "$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $4}' )" )
    
    elif [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic ^Oracle\ Linux ) > 0 ]]; then
      _json=$( json.set --json ${_json} --key .olvm.name  --value "other_linux" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "oracle" )
      _json=$( json.set --json ${_json} --key .os.family  --value "linux" )
      _json=$( json.set --json ${_json} --key .os.version --value "$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $3}' )" )
    
    elif [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic Oracle\ Solaris ) > 0 ]]; then
      _json=$( json.set --json ${_json} --key .olvm.name  --value "other_linux" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "solaris" )
      _json=$( json.set --json ${_json} --key .os.family  --value "unix" )
      _json=$( json.set --json ${_json} --key .os.version --value "$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $3}' )" )
    
    elif [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic ^Other\ Linux ) > 0 ]]; then
      _json=$( json.set --json ${_json} --key .olvm.name  --value "other_linux" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "other" )
      _json=$( json.set --json ${_json} --key .os.family  --value "linux" )
      _json=$( json.set --json ${_json} --key .os.version --value null )
    
    elif [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic ^Other ) > 0 ]]; then
      _json=$( json.set --json ${_json} --key .olvm.name  --value "other_linux" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "other" )
      _json=$( json.set --json ${_json} --key .os.family  --value "linux" )
      _json=$( json.set --json ${_json} --key .os.version --value "$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $2}' )" )
    
    elif [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic Red\ Hat\ Enterprise\ Linux ) > 0 ]]; then
      _os_release=$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $5}' ) 

      _json=$( json.set --json ${_json} --key .os.family  --value "linux" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "rhel" )
      _json=$( json.set --json ${_json} --key .os.version --value "$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $5}' )" )
      _json=$( json.set --json ${_json} --key .olvm.name  --value "rhel_${_os_release}${_arch_suffix}" )

    elif [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic SUSE\ Linux\ Enterprise ) > 0 ]]; then
      _os_release=$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $4}' ) 

      _json=$( json.set --json ${_json} --key .olvm.name  --value "sles_${_os_release}" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "suse" )
      _json=$( json.set --json ${_json} --key .os.family  --value "linux" )
      _json=$( json.set --json ${_json} --key .os.version --value "$( ${cmd_echo} ${osfamily} | ${cmd_awk} '{print $4}' )" )
    
    elif [[ $( ${cmd_echo} ${osfamily} | ${cmd_grep} -ic Ubuntu\ Linux ) > 0 ]]; then
      _json=$( json.set --json ${_json} --key .olvm.name  --value "ubuntu_12_04" )
      _json=$( json.set --json ${_json} --key .os.distro  --value "ubuntu" )
      _json=$( json.set --json ${_json} --key .os.family  --value "linux" )
      _json=$( json.set --json ${_json} --key .os.version --value null )
    
    else
      _json=$( json.set --json ${_json} --key .olvm.name  --value null )
      _json=$( json.set --json ${_json} --key .os.distro  --value "unknown" )
      _json=$( json.set --json ${_json} --key .os.family  --value "unknown" )
      _json=$( json.set --json ${_json} --key .os.version --value null )
    
    fi

    ${cmd_echo} $( date.pretty ) - Parsing OSFamily ${osfamily}

    ${cmd_echo} ${_json} | ${cmd_jq} > ${_path}/osfamilies/"$( ${cmd_echo} ${osfamily} | ${cmd_sed} 's/\///g' )".json

  done

  _exit_string="${_json}"

  # exit
  return ${_exit_code}
}