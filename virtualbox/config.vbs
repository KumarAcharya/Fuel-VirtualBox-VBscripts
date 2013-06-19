
' The number of nodes for installing OpenStack on
'   - for minimal non-HA installation, specify 2 (1 controller + 1 compute)
'   - for minimal non-HA with Cinder installation, specify 3 (1 ctrl + 1 compute + 1 cinder)
'   - for minimal HA installation, specify 4 (3 controllers + 1 compute)
cluster_size=3

' Get the first available ISO from the directory 'iso'
iso_path="iso\fuelweb-centos-3.0.iso"
' Every Fuel Web machine name will start from this prefix  
vm_name_prefix="fuel-web-"

' Host interfaces to bridge VMs interfaces with
' One cannot name host-only interfaces in Windows. So parameters 'host_nic_name(x)' will be rewrited after creating interface.
redim host_nic_name(2), host_nic_ip(2), host_nic_mask(2)

host_nic_name(0)="VirtualBox Host-Only Ethernet Adapter #2"
host_nic_ip(0) = "10.20.0.1"
host_nic_mask(0) = "255.255.255.0"

host_nic_name(1)="VirtualBox Host-Only Ethernet Adapter #3"
host_nic_ip(1) = "240.0.1.1"
host_nic_mask(1) = "255.255.255.0"

host_nic_name(2)="VirtualBox Host-Only Ethernet Adapter #4"
host_nic_ip(2) = "172.16.0.1"
host_nic_mask(2) = "255.255.255.0"

' Master node settings
vm_master_cpu_cores=1
vm_master_memory_mb=1024
vm_master_disk_mb=16384
' These settings will be used to check if master node has installed or not.
' If you modify networking params for master node during the boot time
'   (i.e. if you pressed Tab in a boot loader and modified params),
'   make sure that these values reflect that change.
vm_master_ip="10.20.0.2"
vm_master_username="root"
vm_master_password="r00tme"

' Slave node settings
vm_slave_cpu_cores=1

' This section allows you to define RAM size in MB for each slave node.
' Keep in mind that PXE boot might not work correctly with values lower than 768.
' You can specify memory size for the specific slaves, other will get default vm_slave_memory_default
vm_slave_memory_default = 768
redim vm_slave_memory_mb(3)
vm_slave_memory_mb(1) = 768   ' for controller node 768 MB should be sufficient
vm_slave_memory_mb(2) = 1024  ' for compute node 1GB is recommended, otherwise VM instances in OpenStack may not boot
vm_slave_memory_mb(3) = 768   ' for a dedicated Cinder node 768 MB should be sufficient

' This section allows you to define HDD size in MB for all the slaves nodes.
' All the slaves will have identical disk configuration. Each slave will have three disks of the following sizes.
vm_slave_first_disk_mb=16384
vm_slave_second_disk_mb=512000
vm_slave_third_disk_mb=2300000
