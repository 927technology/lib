docker.image.clean() {
  IFS=$'\n'   # because IFS sucks

  # local variables
  local _count_image=0
  local _json="{}"
  local _json_images="{}"
  local _tag=docker.image.clean

  # control variables
  local _exit_code=${exit_unkn}
  local _exit_string=

  # argument variables
  # none
  
  # parse arguments
  # none

  # main
  shell.log --tag ${_tag} --message "starting image cleanup"

  # create json images key
  _json_images=$( json.set --json "${_json_images}" --key .images --value "[]" )

  # itterate images
  for image in $( docker.image.list | ${cmd_jq} -cr '.[] | if(.Repository == .ID) then . else empty end' ); do 
    # get image id
    _image_id=$( ${cmd_echo} ${image} | ${cmd_jq} -r '.ID' )
    shell.log --tag ${_tag} --message "found image ${_image_id}"

    # add image to json
    _json_images[${_count_image}]=$( json.set --json "${_json_images}" --key .images[${_count_images}] --value "${image}" )

    # remove image
    ${cmd_docker} rmi ${_image_id}
    if [[ ${?} == ${exit_ok} ]]; then
      _json_images[${_count_image}]=$( json.set --json "${_json_images}" --key .images[${_count_images}].success --value ${true} )
      shell.log --tag ${_tag} --message "${_image_id} deleted successfully"

    else  
      _json_images[${_count_image}]=$( json.set --json "${_json_images}" --key .images[${_count_images}].success --value ${false} )
      shell.log --tag ${_tag} --message "${_image_id} deleted unsuccessfully"
      (( _error_count++ ))
    fi
  done

  # finish 
  shell.log --tag ${_tag} --message "finished image cleanup"

  # build json list form _json_volume_attachment array
  _json=$( ${cmd_echo} "${_json_images}" | ${cmd_jq} -c )



  # set exit string
  _exit_string=${_json}

  # exit
  ${cmd_echo} ${_json}
  return ${_exit_code}
}