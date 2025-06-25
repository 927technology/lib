. ${_lib_root}/variables/bools.v
. ${_lib_root}/variables/exits.v

case $( uname -s ) in
  Darwin )
    . ${_lib_root}/variables/cmd/darwin.v

  ;;
  Linux )
    if    [[ -f /etc/redhat-release ]]; then
      . ${_lib_root}/variables/cmd/el.v

    elif  [[ -f /etc/lsb-release ]]; then
      . ${_lib_root}/variables/cmd/debian.v

    fi
  ;;
esac