# NSX-T Manager Credentials
provider "nsxt" {
  host                  = var.nsx_manager
  username              = var.username
  password              = var.password
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

# Data Sources we need for reference later
data "nsxt_policy_transport_zone" "overlay_tz" {
  display_name = var.overlay_tz
}

data "nsxt_policy_transport_zone" "vlan_tz" {
  display_name = var.vlan_tz
}

data "nsxt_policy_edge_cluster" "edge_cluster" {
  display_name = var.edge_cluster
}

data "nsxt_policy_edge_node" "edge_node_1" {
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path
  display_name      = var.edge_node_1
}

data "nsxt_policy_edge_node" "edge_node_2" {
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path
  display_name      = var.edge_node_2
}

# Create NSX-T VLAN Segments
resource "nsxt_policy_vlan_segment" "nsx-vlan-fa-seg" {
  display_name        = var.segment_fa_vlan_name
  description         = "VLAN Segment created by Terraform"
  transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
  vlan_ids            = [var.segment_fa_vlan_id]
}

# LINE 57 - Uncomment lines 58-63 if using Fabric B uplinks 
#resource "nsxt_policy_vlan_segment" "nsx-vlan-fb-seg" {
#  display_name        = var.segment_fb_vlan_name
#  description         = "VLAN Segment created by Terraform"
#  transport_zone_path = data.nsxt_policy_transport_zone.vlan_tz.path
#  vlan_ids            = [var.segment_fb_vlan_id]
#}

# Create Tier-0 Gateway
resource "nsxt_policy_tier0_gateway" "tf-tier0-gw" {
  display_name         = "TF_Tier_0"
  description          = "Tier-0 provisioned by Terraform"
  failover_mode        = "NON_PREEMPTIVE"
  default_rule_logging = false
  enable_firewall      = false
  # force_whitelisting        = true
  ha_mode           = "ACTIVE_ACTIVE"
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path

  bgp_config {
    ecmp            = true
    local_as_num    = var.tier0_local_as
    inter_sr_ibgp   = true
    multipath_relax = true
  }

  redistribution_config {
    enabled = true
    rule {
      name  = "t0-route-redistribution"
      types = ["TIER1_LB_VIP", "TIER1_CONNECTED", "TIER1_SERVICE_INTERFACE", "TIER1_NAT", "TIER1_LB_SNAT"]
    }
  }

}

# Create Tier-0 Gateway Uplink Interfaces

# Edge Node 1 - Fabric A - Router Port Configuration
resource "nsxt_policy_tier0_gateway_interface" "uplink_en1_fa" {
  display_name   = "uplink-en01a-fa"
  description    = "Uplink Edge Node 01a - Fabric A"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.edge_node_1.path
  gateway_path   = nsxt_policy_tier0_gateway.tf-tier0-gw.path
  segment_path   = nsxt_policy_vlan_segment.nsx-vlan-fa-seg.path
  subnets        = [var.uplink_en1_fa_ip]
  mtu            = var.tier0_uplink_mtu
}

# Edge Node 2 - Fabric A - Router Port Configuration
resource "nsxt_policy_tier0_gateway_interface" "uplink_en2_fa" {
  display_name   = "uplink-en01b-fa"
  description    = "Uplink Edge Node 01b - Fabric A"
  type           = "EXTERNAL"
  edge_node_path = data.nsxt_policy_edge_node.edge_node_2.path
  gateway_path   = nsxt_policy_tier0_gateway.tf-tier0-gw.path
  segment_path   = nsxt_policy_vlan_segment.nsx-vlan-fa-seg.path
  subnets        = [var.uplink_en2_fa_ip]
  mtu            = var.tier0_uplink_mtu
}

# LINE 119 - Uncomment lines 120-142 if using Fabric B uplinks 
# Edge Node 1 - Fabric B - Router Port Configuration
#resource "nsxt_policy_tier0_gateway_interface" "uplink_en1_fb" {
#  display_name   = "uplink-en1-fb"
#  description    = "Uplink Edge Node 1 - Fabric B"
#  type           = "EXTERNAL"
#  edge_node_path = data.nsxt_policy_edge_node.edge_node_1.path
#  gateway_path   = nsxt_policy_tier0_gateway.tf-tier0-gw.path
#  segment_path   = nsxt_policy_vlan_segment.nsx-vlan-fb-seg.path
#  subnets        = [var.uplink_en1_fb_ip]
#  mtu            = var.tier0_uplink_mtu
#}

# Edge Node 2 - Fabric B - Router Port Configuration
#resource "nsxt_policy_tier0_gateway_interface" "uplink_en2_fb" {
#  display_name   = "uplink-en1-fb"
#  description    = "Uplink Edge Node 2 - Fabric A"
#  type           = "EXTERNAL"
#  edge_node_path = data.nsxt_policy_edge_node.edge_node_2.path
#  gateway_path   = nsxt_policy_tier0_gateway.tf-tier0-gw.path
#  segment_path   = nsxt_policy_vlan_segment.nsx-vlan-fb-seg.path
#  subnets        = [var.uplink_en2_fb_ip]
#  mtu            = var.tier0_uplink_mtu
#}

# Local definitions
locals {
  # Concatinate Uplink Source IPs for ToR-A Peering
  peer_a_source_addresses = concat(
    nsxt_policy_tier0_gateway_interface.uplink_en1_fa.ip_addresses,
    nsxt_policy_tier0_gateway_interface.uplink_en2_fa.ip_addresses
  )

# LINE 152 - Uncomment lines 154-157 if using Fabric B Networks 
  # Concatinate Uplink Source IPs for ToR-B Peering 
#  peer_b_source_addresses = concat(
#    nsxt_policy_tier0_gateway_interface.uplink_en1_fb.ip_addresses,
#    nsxt_policy_tier0_gateway_interface.uplink_en2_fb.ip_addresses
#  )
}

# BGP Neighbor Configuration ToR-A
resource "nsxt_policy_bgp_neighbor" "router_a" {
  display_name     = "ToR-A"
  description      = "Terraform provisioned BGP Neighbor Configuration"
  bgp_path         = nsxt_policy_tier0_gateway.tf-tier0-gw.bgp_config.0.path
  neighbor_address = var.router_a_ip
  remote_as_num    = var.router_a_remote_as
  hold_down_time   = var.hold_down_time
  keep_alive_time  = var.keep_alive_time
}

# LINE 171 - Uncomment lines 173-181 if using Fabric B Networks 
# BGP Neighbor Configuration ToR-B
#resource "nsxt_policy_bgp_neighbor" "router_b" {
#  display_name     = "ToR-B"
#  description      = "Terraform provisioned BGP Neighbor Configuration"
#  bgp_path         = nsxt_policy_tier0_gateway.tf-tier0-gw.bgp_config.0.path
#  neighbor_address = var.router_b_ip
#  remote_as_num    = var.router_b_remote_as
#  hold_down_time   = var.hold_down_time
#  keep_alive_time  = var.keep_alive_time
#}

# Create Tier-1 Gateway
resource "nsxt_policy_tier1_gateway" "tf-tier1-gw" {
  description               = "Tier-1 provisioned by Terraform"
  display_name              = "TF-Tier-1-01"
  nsx_id                    = "predefined_id"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
  failover_mode             = "NON_PREEMPTIVE"
  default_rule_logging      = "false"
  enable_firewall           = "true"
  enable_standby_relocation = "false"
  # force_whitelisting        = "false"
  tier0_path                = nsxt_policy_tier0_gateway.tf-tier0-gw.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED"]
}

# DHCP Server
resource "nsxt_policy_dhcp_server" "dhcp_server" {
  display_name      = "DHCP Server"
  description       = "Terraform provisioned DHCP Server Config"
  edge_cluster_path = data.nsxt_policy_edge_cluster.edge_cluster.path
  lease_time        = 86400
}

# Create NSX-T Overlay Segments
resource "nsxt_policy_segment" "tf_segment_hzn_cs" {
  display_name        = var.segment_hzn_cs
  description         = "Segment created by Terraform"
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
  connectivity_path   = nsxt_policy_tier1_gateway.tf-tier1-gw.path
  dhcp_config_path    = nsxt_policy_dhcp_server.dhcp_server.path

  subnet {
    cidr        = var.segment_hzn_cs_cidr
    dhcp_ranges = [var.segment_hzn_cs_dhcp_range]

    dhcp_v4_config {
      server_address = var.segment_hzn_cs_dhcp_server_address
      lease_time     = 86400
      dns_servers    = [var.segment_hzn_cs_dhcp_dns_server]
    }
  }

  tag {
    scope       = var.segment_hzn_scope
    tag         = var.segment_hzn_cs_tag
  }
}

resource "nsxt_policy_segment" "tf_segment_hzn_uag" {
  display_name        = var.segment_hzn_uag
  description         = "Segment created by Terraform"
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
  connectivity_path   = nsxt_policy_tier1_gateway.tf-tier1-gw.path
  dhcp_config_path    = nsxt_policy_dhcp_server.dhcp_server.path

  subnet {
    cidr        = var.segment_hzn_uag_cidr
    dhcp_ranges = [var.segment_hzn_uag_dhcp_range]

    dhcp_v4_config {
      server_address = var.segment_hzn_uag_dhcp_server_address
      lease_time     = 86400
      dns_servers    = [var.segment_hzn_uag_dhcp_dns_server]
    }
  }

    tag {
    scope       = var.segment_hzn_scope
    tag         = var.segment_hzn_uag_tag
  }
}

resource "nsxt_policy_segment" "tf_segment_ent_svc" {
  display_name        = var.segment_ent_svc
  description         = "Segment created by Terraform"
  transport_zone_path = data.nsxt_policy_transport_zone.overlay_tz.path
  connectivity_path   = nsxt_policy_tier1_gateway.tf-tier1-gw.path
  dhcp_config_path    = nsxt_policy_dhcp_server.dhcp_server.path

  subnet {
    cidr        = var.segment_ent_svc_cidr
    dhcp_ranges = [var.segment_ent_svc_dhcp_range]

    dhcp_v4_config {
      server_address = var.segment_ent_svc_dhcp_server_address
      lease_time     = 86400
      dns_servers    = [var.segment_ent_svc_dhcp_dns_server]
    }
  }

    tag {
    scope       = var.segment_ent_svc_scope
    tag         = var.segment_ent_svc_tag
  }
}

