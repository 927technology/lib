
. ${_lib_root}/move/create/olvm/datacenters.f
. ${_lib_root}/move/create/osfamilies/map.f

. ${_lib_root}/move/delete/transfers.f
. ${_lib_root}/move/delete/vms.f

. ${_lib_root}/move/create/network/map.f
. ${_lib_root}/move/create/vms.f

. ${_lib_root}/move/coriolis/create/deployment.f
. ${_lib_root}/move/coriolis/create/transfers.f
. ${_lib_root}/move/coriolis/create/transfer/schedules.f
. ${_lib_root}/move/coriolis/delete/transfer.f
. ${_lib_root}/move/coriolis/list/active.f
. ${_lib_root}/move/coriolis/list/endpoints.f
. ${_lib_root}/move/coriolis/list/endpoints/networks.f
. ${_lib_root}/move/coriolis/list/endpoints/destination/options.f
. ${_lib_root}/move/coriolis/list/endpoints/source/options.f
. ${_lib_root}/move/coriolis/list/endpoints/storage.f

. ${_lib_root}/move/coriolis/list/deployments.f
# . ${_lib_root}/move/coriolis/list/servers.f
. ${_lib_root}/move/coriolis/list/transfers.f
. ${_lib_root}/move/coriolis/list/transfers/schedules.f
. ${_lib_root}/move/coriolis/set/endpoint.f
. ${_lib_root}/move/coriolis/set/server.f
. ${_lib_root}/move/coriolis/validate/transfers.f

. ${_lib_root}/move/edit/transfers.f
. ${_lib_root}/move/edit/network/map.f

. ${_lib_root}/move/list/profile/active.f
. ${_lib_root}/move/list/profiles.f
. ${_lib_root}/move/list/transfers.f
. ${_lib_root}/move/list/transfers/active.f
. ${_lib_root}/move/list/network/map.f
. ${_lib_root}/move/list/olvm/datacenters.f
. ${_lib_root}/move/list/osfamilies/map.f
. ${_lib_root}/move/list/vms.f

. ${_lib_root}/move/naemon/create/hosts.f
. ${_lib_root}/move/naemon/create/profiles.f

. ${_lib_root}/move/reload.f

. ${_lib_root}/move/set/profile.f
. ${_lib_root}/move/set/transfers.f
. ${_lib_root}/move/set/network/map.f

. ${_lib_root}/move/validate/transfers.f
# . ${_lib_root}/move/validate/key/coriolis_transfer_destination.f
. ${_lib_root}/move/validate/key/coriolis_transfer_destination_cluster.f
. ${_lib_root}/move/validate/key/coriolis_transfer_destination_delete-protected.f
. ${_lib_root}/move/validate/key/coriolis_transfer_destination_leave-migrated-vms-off.f
. ${_lib_root}/move/validate/key/coriolis_transfer_destination_migr-blank-template.f
. ${_lib_root}/move/validate/key/coriolis_transfer_destination_migr-minion-storage-domain.f
. ${_lib_root}/move/validate/key/coriolis_transfer_destination_optimized-for.f
. ${_lib_root}/move/validate/key/coriolis_transfer_destination_os-release.f
. ${_lib_root}/move/validate/key/coriolis_transfer_destination_set-dhcp.f
# . ${_lib_root}/move/validate/key/coriolis_transfer_endpoint.f
. ${_lib_root}/move/validate/key/coriolis_transfer_source_automatically-enable-cbt.f
. ${_lib_root}/move/validate/key/harddisks.f
# . ${_lib_root}/move/validate/key/move_coriolis_schedule.f
. ${_lib_root}/move/validate/key/networkadapters.f


. ${_lib_root}/move/vsphere/list/active.f
. ${_lib_root}/move/vsphere/list/endpoints.f
. ${_lib_root}/move/vsphere/set/endpoint.f
. ${_lib_root}/move/vsphere/list/vms.f