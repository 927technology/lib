brig.create.chroot() {
  # local variables
  local _chroot_path=/opt/brig
  declare -a local _chroot_directories=(
    /bin
    /dev
    /etc
    /usr
  )
  declare -a local _chroot_bind_files=(
    /bin/bash
    /bin/ls
    /dev/null
    /etc/bashrc
    /etc/environment
    /etc/passwd
    /etc/profile
    /usr/bin/ls
    /usr/bin/uname
  )
  declare -a local _chroot_bind_directories=(
    /home
    /lib64
    /usr/share/terminfo
    /usr/libexec
  )

  # argument variables
  local _app=

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  # parse arguments
  while [[ ${1} != "" ]]; do
   case ${1} in 
     -a | --app )
        shift
        _app="${1}"
     ;; 
    esac
    shift
  done

  # main
  # create chroot home
  if [[ ! -d ${_chroot_path}/${_app} ]]; then
    ${cmd_echo} "[CREATE] - ${_chroot_path}/${_app}"
    ${cmd_mkdir} ${_chroot_path}/${_app}
  fi

  # create chroot directories
  for chroot_directory in ${_chroot_directories[@]}; do
    if [[ ! -d ${_chroot_path}/${_app}${chroot_directory} ]]; then
      ${cmd_echo} "[CREATE] - ${_chroot_path}/${_app}${chroot_directory}"
      ${cmd_mkdir} --parents ${_chroot_path}/${_app}${chroot_directory}
    
    fi
  done

  # create chroot bind directories
  for chroot_bind_directory in ${_chroot_bind_directories[@]}; do
    if [[ ! -d ${_chroot_path}/${_app}${chroot_bind_directory} ]]; then
      ${cmd_echo} "[CREATE] - ${_chroot_path}/${_app}${chroot_bind_directory}"
      ${cmd_mkdir} --parents ${_chroot_path}/${_app}${chroot_bind_directory}
    
    fi

    # mount
    if ! ${cmd_mountpoint} ${_chroot_path}/${_app}${chroot_bind_directory} >/dev/null 2>&1; then 
      ${cmd_echo} "[MOUNT ] - ${chroot_bind_directory} -> ${_chroot_path}/${_app}${chroot_bind_directory}"
      ${cmd_mount} --bind ${chroot_bind_directory} ${_chroot_path}/${_app}${chroot_bind_directory}
    
    fi 
  done

  # create chroot bind files
  for chroot_bind_file in ${_chroot_bind_files[@]}; do
    if  [[ ! -f ${_chroot_path}/${_app}${chroot_bind_file} ]] && \
        [[ ! -c ${_chroot_path}/${_app}${chroot_bind_file} ]]; then
      ${cmd_echo} "[CREATE] - ${chroot_bind_file} -> ${_chroot_path}/${_app}${chroot_bind_file}"
      ${cmd_touch} ${_chroot_path}/${_app}${chroot_bind_file}
  
    fi

    # mount
    if ! ${cmd_mountpoint} ${_chroot_path}/${_app}${chroot_bind_file} >/dev/null 2>&1; then
      ${cmd_echo} "[MOUNT ] - ${chroot_bind_file} -> ${_chroot_path}/${_app}${chroot_bind_file}"
      ${cmd_mount} --bind ${chroot_bind_file} ${_chroot_path}/${_app}${chroot_bind_file}

    fi
  
  done



  # exit
  [[ ${_error_count} != 0 ]] && _exit_code=${exit_crit} || _exit_code=${exit_ok}

  return ${_exit_code}
}