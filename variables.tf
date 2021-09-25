# Variables
# Replace with IP address or FQDN of NSX Manager
variable "nsx_manager" {
  default = "nsx.projectonestone.io"
}

# Username & Password for NSX-T Manager
variable "username" {
  default = "admin"
}

variable "password" {
  default = "VMware1!VMware1!"
}

# Replace with IP address of Domain vCenter Server Appliance
variable "vcenter_server" {
  default = "10.26.11.100"
}

# Replace with VM naming convention for AD/LDAP Servers
variable "ad_servers_vm_name" {
  default = "FDB1N801"
}

# Replace with VM naming convention for SQL Servers
variable "mssql_servers_vm_name" {
  default = "FDB1N80202"
}

# Replace with VM naming convention for Workspace ONE Access appliances (if Using)
variable "ws1a_servers_vm_name" {
  default = "FDB1N803"
}

# Replace with VM naming convention for Connection Servers
variable "cs_servers_vm_name" {
  default = "FDB1N804"
}

# Replace with VM naming convention for UAG appliances
variable "uag_servers_vm_name" {
  default = "FDB1N805"
}

# Replace IP address if using a load balancer (VIP) for UAGs
variable "uag_vip_ip" {
  default = "10.16.0.5"
}

# Replace IP address if using a load balancer (VIP) for Connection Servers
variable "cs_vip_ip" {
  default = "10.16.0.7"
}

# Replace CIDR address if using NSX Advanced Load Balancer service engines (SE-Data) 
# and not using Tag for Segment
variable "avi_se_data_cidr" {
  default = "10.16.21.0/24"
}

# Desktop Pools
# If using scope, include "tag|scope" criteria
# If using tag, include only the tag criteria
variable "vdi_pool_tag" {
  default = "vdi"  
}

variable "vdi_pool_vm_name" {
  default = "FDB1N9"  
}

# If using Avi Load Balancer, replace value with appropriate value.  
# If using scope, include "tag|scope" criteria
# If using tag, include only the tag criteria
variable "avi_se_tag" {
  default = "avi|se"
}
