proxmox.enable.sleep() {
  # dependancies

  # local variables

  # control variables
  # none

  #parse arguments
  # none

  # control variables
  # none

  # main
  ${cmd_systemctl}            \ 
    unmask                    \
      sleep.target            \
      suspend.target          \
      hibernate.target        \
      hybrid-sleep.target 

  return ${?}  
}
