#curl -s Https://927technology.github.io/ops/infrastructure.json | jq '.hosts.clouds[] | select(.name=="cmurray").tennants[] | select(.name=="cmurray/927").iac[0].compartments
#oci.iam.compartment.list --profile DEFAULT --id ocid1.tenancy.oc1..aaaaaaaa4k7ux473pugxgzjasoae2ej2ya3kdvemxnuveimz4qfo3orssmeq


# for test in $(oci.iam.compartment.list --profile DEFAULT --id ocid1.tenancy.oc1..aaaaaaaa4k7ux473pugxgzjasoae2ej2ya3kdvemxnuveimz4qfo3orssmeq | jq '.[].description') ; do 
#   echo ${test} 
#   echo  
# done


#!/bin/bash
# description
# extras
IFS=$'\n'

# variables
_json_ai=
_json_oci=
_lib_root=/home/bryan/Desktop/git/lib/bash/0.4.0

# libraries

. ${_lib_root}/oci.l
. ${_lib_root}/json.l
. ${_lib_root}/variables.l
. ${_lib_root}/standard.l

# main
_json_ai=$(curl -s Https://927technology.github.io/ops/infrastructure.json | jq -c '.hosts.clouds[] | select(.name=="cmurray").tennants[] | select(.name=="cmurray/927").iac[0].compartments')
_json_oci=$(oci.iam.compartment.list --profile DEFAULT --id ocid1.tenancy.oc1..aaaaaaaa4k7ux473pugxgzjasoae2ej2ya3kdvemxnuveimz4qfo3orssmeq)

echo "${_json_ai}" | jq
echo
echo "${_json_oci}" | jq

# for test in $(echo ${_json_ai} | jq -c '.[]') ; do 
#   echo ${test} | jq -r '.label'
#   echo  
# done

# for test in $(echo ${_json_oci} | jq -c '.[]') ; do 
#   echo ${test} | jq -r 'if(."defined-tags"."927-ops".label==null) then empty else . end'
#   echo  
# done


# exit

#homework
# created nested for loop for labels starting on line 36 compare the labels for the loop on line 41


# for A in $(echo ${_json_ai} | jq -c '.[]') ; do 
#   unset ${_A2}
#   _A2=$(echo ${A} | jq -r '.label')
#   echo "set A:"${_A2} 
#   for B in $(echo ${_json_oci} | jq -c '.[]'); do
#     unset ${_B2}
#     #unset ${_B3}
#     #_B3=$(echo ${B} | jq -r '."defined-tags"')
#     #echo ${_B3}
#     _B2=$(echo ${B} | jq -r 'if(."defined-tags"."927-ops".label==null) then empty else . end')
#     echo "set B:" ${_B2}
#   done
# done

for A in "$(echo ${_json_ai} | jq -c '.[]')" ; do 
  for B in "$(echo ${_json_oci} | jq -c '.[]')" do 
    if [[ "${A}"=="${B}"]]; then
      ${found}=true
      break
    fi
  done
  if ! ${found}; then
    echo "Not Found: ${A}"
  fi
done
