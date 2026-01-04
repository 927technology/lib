proxmox.install.usb_console() {
  # dependancies

  # local variables

  # control variables
  local _error_count=0
  local _exit_code=${exit_unkn}
  local _exit_string=

  parse arguments
  while [[ ${1} != "" ]]; do
    case ${1} in
      -akn  | --api-key-name )
        shift
        _api_key_name=$( ${cmd_echo} "${1}" | lcase )
      ;;
    esac
    shift
  done

  # control variables
  # none

  # main
  # comment out existing 
  sed --in-place 's/^GRUB_CMDLINE_LINUX_DEFAULT="quiet"/# GRUB_CMDLINE_LINUX_DEFAULT="quiet"/g' /etc/default/grub

  # add new
  cat << EOF_GRUB >> /etc/default/grub
# 927 console config
GRUB_CMDLINE_LINUX_DEFAULT="console=tty0 console=ttyUSB0,9600n8"
GRUB_TERMINAL="serial"
GRUB_SERIAL_COMMAND="SERIAL --speed=9600 --unit=0 --word=8 --parity=no --stop=1"
EOF_GRUB

  ${cmd_update_grub}

  ${cmd_systemctl} enable serial-getty@ttyUSB0.service
  ${cmd_systemctl} start serial-getty@ttyUSB0.service
}
