# Variables
# NSX Manager
variable "nsx_manager" {
  default = "nsx01.pod2.demo"
}

# Username & Password for NSX-T Manager
variable "username" {
  default = "admin"
}

variable "password" {
  default = "VMware1!VMware1!"
}

# Transport Zones & MTU
variable "vlan_tz" {
  default = "nsx-vlan-transportzone"
}

variable "overlay_tz" {
  default = "nsx-overlay-transportzone"
}

variable "tier0_uplink_mtu" {
  default = "1500"
}

# Enter Edge Nodes Display Name. Required for external interfaces.
variable "edge_node_1" {
  default = "edge01a"
}
variable "edge_node_2" {
  default = "edge01b"
}

variable "edge_cluster" {
  default = "nsx-pod2-ec01"
}

# VLAN Segment Names and Details. Required for external interfaces.
variable "segment_fa_vlan_name" {
  default = "nsx-pod2-3302-vlan"
}
  
variable "segment_fa_vlan_id" {
  default = "3302"
}

variable "segment_fb_vlan_name" {
  default = "nsx-vlan-2812-seg"
}
  
variable "segment_fb_vlan_id" {
  default = "2812"
}

# Tier0 Gateway Configuration
variable "tier0_local_as" {
  default = 3302
}

variable "uplink_en1_fa_ip" {
  default = "10.33.2.1/24"
}

variable "uplink_en2_fa_ip" {
  default = "10.33.2.2/24"
}

variable "uplink_en1_fb_ip" {
  default = "10.28.12.1/24"
}

variable "uplink_en2_fb_ip" {
  default = "10.28.12.2/24"
}

variable "router_a_ip" {
  default = "10.33.2.253"
}

variable "router_b_ip" {
  default = "10.28.12.253"
}

variable "router_a_remote_as" {
  default = "65000"
}

variable "router_b_remote_as" {
  default = "65000"
}

variable "hold_down_time" {
  default = "180"
}

variable "keep_alive_time" {
  default = "60"
}

# Overlay Segment Names and Details
variable "segment_hzn_cs" {
  default = "TF-Segment-HZN-CS"
}

variable "segment_hzn_scope" {
  default = "horizon"
}

variable "segment_hzn_cs_tag" {
  default = "cs"
}

variable "segment_hzn_uag" {
  default = "TF-Segment-HZN-UAG"
}

variable "segment_hzn_uag_tag" {
  default = "uag"
}

variable "segment_ent_svc" {
  default = "TF-Segment-ENT-SVC"
}

variable "segment_ent_svc_scope" {
  default = "domain"
}

variable "segment_ent_svc_tag" {
  default = "ent_svc"
}

variable "segment_hzn_cs_cidr" {
  default = "10.202.30.253/24"
}

#Web Segment DHCP IP Address Range
variable "segment_hzn_cs_dhcp_range" {
  default = "10.202.30.101-10.202.30.200"
}

#Web Segment DHCP Server (Gateway)
variable "segment_hzn_cs_dhcp_server_address" {
  default = "10.202.30.254/24"
}

#Web Segment DHCP DNS Server
variable "segment_hzn_cs_dhcp_dns_server" {
  default = "10.16.0.8"
}

variable "segment_hzn_uag_cidr" {
  default = "10.202.20.253/24"
}

#App Segment DHCP IP Address Range
variable "segment_hzn_uag_dhcp_range" {
  default = "10.202.20.101-10.202.20.200"
}

#App Segment DHCP Server (Gateway)
variable "segment_hzn_uag_dhcp_server_address" {
  default = "10.202.20.254/24"
}

#App Segment DHCP DNS Server
variable "segment_hzn_uag_dhcp_dns_server" {
  default = "10.16.0.8"
}

variable "segment_ent_svc_cidr" {
  default = "10.202.10.253/24"
}

#DB Segment DHCP IP Address Range
variable "segment_ent_svc_dhcp_range" {
  default = "10.202.10.101-10.202.10.200"
}

#DB Segment DHCP Server (Gateway)
variable "segment_ent_svc_dhcp_server_address" {
  default = "10.202.10.254/24"
}

#DB Segment DHCP DNS Server
variable "segment_ent_svc_dhcp_dns_server" {
  default = "10.16.0.8"
}
