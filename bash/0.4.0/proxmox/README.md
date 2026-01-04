# **927 Technology - Bash Libraries**

### proxmox

|Name|Arguments|Output|Description|
|:---|:-|:-|:-------------|
|[proxmox.create.vm](./create/vm.f)|See Usage|JSoN of created Resource|request creation of a VM resource via the API|



## Usage

##### -akn  | --api-key-name
> Required: The name of the API token-id in Proxmox </br>Datacenter/Permissions/API Tokens 

##### -akv  | --api-key-value
> Required: The value of the API token in Proxmox </br>Datacenter/Permissions/API Tokens 


##### -au  | --api-user
> Required: The name of the API user in Proxmox </br>Datacenter/Permissions/Users

##### -aur  | --api-user-realm
> Required: The name of the API user's realm in Proxmox </br>Datacenter/Permissions/Users

##### -h  | --host
> Required: The name/IP of the Proxmox management node

##### -hp  | --host-port
> Optional: The port the Proxmox host listens on</br>Default: 8006

##### -n | --node
> Required: The name of the Proxmox node to perform the request on

##### -p  | --path
> Depricated: The API path for the resource</br>Default: nodes/${_node}/qemu

##### \c<vm json>
> JSoN formatted VM attributes</br>[proxmox.json.vm](./json/vm.f)


## Example
```
proxmox.create.vm
  --api-key-name test_api
  --api-key-value b48aae82-7ca7-4c3b-9763-bcd1df3ec065
  --api-user svc_api
  --api-user-realm pve
  --host my.proxmox.com
  --host-port 8006
  --node proxmox-01
  <vm json>
```



&nbsp;
#### Source Command
> . ${_lib_root}/proxmox.l

or

> source ${_lib_root}/proxmox.l