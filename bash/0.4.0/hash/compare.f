hash.compare () {
  # description
  # compares a string value or file contents to another string value or file content

  # dependancies
  # 927.bools.v
  # 927/cmd_<platform>.v
  # 927/nagios.v
  # hash/<algorithm>.f

  # argument variables
  local _algorithm=sha256
  local -a _file=
  local _hash=
  local -a _string=
  
  # control variables
  local _error_count=0
  local _exit_code=${exit_warn}
  local _exit_string=
  local _tag=hash.compare

  # local variables

  # parse command arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -a   | --algorithm )
        shift
        _algorithm=${1}
      ;;
      -f   | --file )
        shift
        _file=( $( ${cmd_echo} ${1} | ${cmd_sed} 's/,/\ /g' ) )
      ;;
      -h   | --hash )
        shift
        _hash=${1}
      ;;
      -s  | --string )
        shift
        _string=( $( ${cmd_echo} ${1} | ${cmd_sed} 's/,/\ /g' ) )
      ;;
    esac
    shift
  done

  # main
  # two files
  if  [[ ${#_file[@]} == 2 ]]             &&  \
      [[ ! -z ${_file[0]} ]]              &&  \
      [[ ! -z ${_file[1]} ]]              &&  \
      [[ -f ${_file[0]} ]]                &&  \
      [[ -f ${_file[1]} ]]
    then

    if [[ $( ${cmd_echo} ${_file[0]} | hash.${_algorithm} ) == $( ${cmd_echo} ${_file[1]} | hash.${_algorithm} ) ]]; then
      _exit_string=${true}
    
    else
      _exit_string=${false}
    
    fi 

    _exit_code=${exit_ok}
  
  # two strings
  elif  [[ ${#_string[@]} == 2 ]]         &&  \
        [[ ! -z ${_string[0]} ]]          &&  \
        [[ ! -z ${_string[1]} ]]
    then

    if [[ $( ${cmd_echo} ${_string[0]} | hash.${_algorithm} ) == $( ${cmd_echo} ${_string[1]} | hash.${_algorithm} ) ]]; then
      _exit_string=${true}
    
    else
      _exit_string=${false}
    
    fi 

    _exit_code=${exit_ok}
  
  # file and string
  elif  [[ ${#_file[@]} == 1 ]]           &&  \
        [[ ${#_string[@]} == 1 ]]         &&  \
        [[ ! -z ${_file[0]} ]]            &&  \
        [[ ! -z ${_string[0]} ]]          &&  \
        [[ -f ${_file[0]} ]]
    then  

    if [[ $( ${cmd_echo} ${_file[0]} | hash.${_algorithm} ) == $( ${cmd_echo} ${_string[0]} | hash.${_algorithm} ) ]]; then
      _exit_string=${true}
    
    else
      _exit_string=${false}
    
    fi 

  # file and hash
  elif  [[ ${#_file[@]} == 1 ]]           &&  \
        [[ ! -z ${_file[0]} ]]            &&  \
        [[ ! -z ${_hash} ]]
    then  

    if [[ $( ${cmd_echo} ${_file[0]} | hash.${_algorithm} ) == ${_hash} ]]; then
      _exit_string=${true}
    
    else
      _exit_string=${false}
    
    fi
  
  # string and hash
  elif  [[ ${#_string[@]} == 1 ]]         &&  \
        [[ ! -z ${_string[0]} ]]          &&  \
        [[ ! -z ${_hash} ]]
    then  

    if [[ $( ${cmd_echo} ${_string[0]} | hash.${_algorithm} ) == ${_hash} ]]; then
      _exit_string=${true}
    
    else
      _exit_string=${false}
    
    fi

  # oops
  else
    _exit_code=${exit_crit}
  
  fi

  # exit
  ${cmd_echo} ${_exit_string}
  return ${_exit_code}
}