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

# Create Security Groups
resource "nsxt_policy_group" "vcenter_server" {
  display_name = "vCenter Server Appliance"
  description  = "vCenter Server Appliance"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.vcenter_server]
    }
  }
}

resource "nsxt_policy_group" "ad_servers" {
  display_name = "HZN-GRP-AD"
  description  = "Active Directory Servers"

  criteria {
    condition {
      key         = "Name"
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      value       = var.ad_servers_vm_name
    }
  }
}

resource "nsxt_policy_group" "mssql_servers" {
  display_name = "HZN-GRP-MSSQL"
  description  = "Horizon SQL Servers"

  criteria {
    condition {
      key         = "Name"
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      value       = var.mssql_servers_vm_name
    }
  }
}

resource "nsxt_policy_group" "connection_servers" {
  display_name = "HZN-GRP-CS"
  description  = "Horizon Connection Servers"

  criteria {
    condition {
      key         = "Name"
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      value       = var.cs_servers_vm_name
    }
  }
}

resource "nsxt_policy_group" "uag_servers" {
  display_name = "HZN-GRP-UAG"
  description  = "Horizon Unified Access Gateway (UAG) Appliances"

  criteria {
    condition {
      key         = "Name"
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      value       = var.uag_servers_vm_name
    }
  }
}

resource "nsxt_policy_group" "ws1a_servers" {
  display_name = "HZN-GRP-WS1A"
  description  = "Workspace ONE Access Servers"

  criteria {
    condition {
      key         = "Name"
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      value       = var.ws1a_servers_vm_name
    }
  }
}

resource "nsxt_policy_group" "cs_vip" {
  display_name = "HZN-GRP-CS-VIP"
  description  = "Horizon Connection Servers VIP"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.cs_vip_ip]
    }
  }
}

resource "nsxt_policy_group" "uag_vip" {
  display_name = "HZN-GRP-UAG-VIP"
  description  = "Horizon UAG VIP"

  criteria {
    ipaddress_expression {
      ip_addresses = [var.uag_vip_ip]
    }
  }
}

resource "nsxt_policy_group" "desktop_pool" {
  display_name = "HZN-GRP-VDI-POOL"
  description  = "Horizon Desktop Pool(s)"

 criteria {
    condition {
      key         = "Tag"
      member_type = "Segment"
      operator    = "EQUALS"
      value       = var.vdi_pool_tag
    }
  }

 conjunction {
     operator = "OR"
  }

  criteria {
    condition {
      key         = "Name"
      member_type = "VirtualMachine"
      operator    = "STARTSWITH"
      value       = var.vdi_pool_vm_name
    }
  }
}

resource "nsxt_policy_group" "lb_data" {
  display_name = "HZN-GRP-LB"
  description  = "Horizon Avi Load Balancer Service Engine(s)"

 criteria {
    condition {
      key         = "Tag"
      member_type = "Segment"
      operator    = "EQUALS"
      value       = var.lb_tag
    }
  }
 
 conjunction {
     operator = "OR"
  }

  criteria {
    ipaddress_expression {
      ip_addresses = [var.lb_data_cidr]
    }
  }
}

# Create Custom Services for Horizon

resource "nsxt_policy_service" "service_hzn_HTTP" {
  description  = "Horizon Horizon Client HTTP"
  display_name = "HZN-SVC-HTTP"

  l4_port_set_entry {
    display_name      = "HZN-SVC-HTTP"
    description       = "Horizon Horizon Client HTTP"
    protocol          = "TCP"
    destination_ports = ["80"]
  }
}

resource "nsxt_policy_service" "service_hzn_HTTPS" {
  description  = "Horizon Horizon Client HTTPS"
  display_name = "HZN-SVC-HTTPS"

  l4_port_set_entry {
    display_name      = "HZN-SVC-HTTPS"
    description       = "Horizon Horizon Client HTTPS"
    protocol          = "TCP"
    destination_ports = ["443"]
  }
}

resource "nsxt_policy_service" "service_hzn_HTTPS_8443" {
  description  = "Horizon Horizon Client HTTPS - 8443"
  display_name = "HZN-SVC-HTTPS-8443"

  l4_port_set_entry {
    display_name      = "HZN-SVC-HTTPS-8443"
    description       = "Horizon Horizon Client HTTPS - 8443"
    protocol          = "TCP"
    destination_ports = ["8443"]
  }
}

resource "nsxt_policy_service" "service_hzn_blast" {
  description  = "Horizon Blast Extreme Desktop Protocol"
  display_name = "HZN-SVC-BLAST"

  l4_port_set_entry {
    display_name      = "HZN-SVC-BLAST-TCP-443"
    description       = "Horizon Blast Extreme TCP 443"
    protocol          = "TCP"
    destination_ports = ["443"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-BLAST-TCP-8443"
    description       = "Horizon Blast Extreme TCP 8443"
    protocol          = "TCP"
    destination_ports = ["8443"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-BLAST-UDP-443"
    description       = "Horizon Blast Extreme UDP 443"
    protocol          = "UDP"
    destination_ports = ["443"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-BLAST-UDP-8443"
    description       = "Horizon Blast Extreme UDP 8443"
    protocol          = "UDP"
    destination_ports = ["8443"]
  }
}

resource "nsxt_policy_service" "service_hzn_pcoip" {
  description  = "Horizon PCOIP Desktop Protocol"
  display_name = "HZN-SVC-PCOIP"

  l4_port_set_entry {
    display_name      = "HZN-SVC-PCOIP-UDP-4172"
    description       = "Horizon PCOIP UDP 4172"
    protocol          = "UDP"
    destination_ports = ["4172"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-PCOIP-TCP-4172"
    description       = "Horizon PCOIP TCP 4172"
    protocol          = "TCP"
    destination_ports = ["4172"]
  }
}

resource "nsxt_policy_service" "service_hzn_blast_22443" {
  description  = "Horizon Agent Blast Extreme - 22443"
  display_name = "HZN-SVC-BLAST-22443"

  l4_port_set_entry {
    display_name      = "HZN-SVC-BLAST-UDP-22443"
    description       = "Horizon BLAST UDP 22443"
    protocol          = "UDP"
    destination_ports = ["22443"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-BLAST-TCP-22443"
    description       = "Horizon BLAST TCP 22443"
    protocol          = "TCP"
    destination_ports = ["22443"]
  }
}

resource "nsxt_policy_service" "service_hzn_rdp" {
  description  = "Horizon RDP Desktop Protocol"
  display_name = "HZN-SVC-RDP"

  l4_port_set_entry {
    display_name      = "HZN-SVC-RDP-3389"
    description       = "Horizon RDP 3389"
    protocol          = "TCP"
    destination_ports = ["3389"]
  }
}

resource "nsxt_policy_service" "service_hzn_cdr" {
  description  = "Horizon Client Drive Redirection"
  display_name = "HZN-SVC-CDR"

  l4_port_set_entry {
    display_name      = "HZN-SVC-CDR-9427"
    description       = "Horizon Client Drive Redirection"
    protocol          = "TCP"
    destination_ports = ["9427"]
  }
}

resource "nsxt_policy_service" "service_hzn_usb" {
  description  = "Horizon USB Drive Redirection"
  display_name = "HZN-SVC-USB"

  l4_port_set_entry {
    display_name      = "HZN-SVC-USB-32111"
    description       = "Horizon USB Drive Redirection"
    protocol          = "TCP"
    destination_ports = ["32111"]
  }
}

resource "nsxt_policy_service" "service_hzn_mssql" {
  description  = "Horizon Connection Server - MSSQL"
  display_name = "HZN-SVC-MSSQL"

  l4_port_set_entry {
    display_name      = "HZN-SVC-MSSQL-1433"
    description       = "Horizon Connection Server - MSSQL"
    protocol          = "TCP"
    destination_ports = ["1433"]
  }
}

resource "nsxt_policy_service" "service_hzn_oracle" {
  description  = "Horizon Connection Server - Oracle"
  display_name = "HZN-SVC-ORACLE"

  l4_port_set_entry {
    display_name      = "HZN-SVC-ORACLE-1521"
    description       = "Horizon Connection Server - ORACLE"
    protocol          = "TCP"
    destination_ports = ["1521"]
  }
}

resource "nsxt_policy_service" "service_hzn_jms_legacy" {
  description  = "Horizon Connection Server - JMS Legacy"
  display_name = "HZN-SVC-JMS-LEGACY"

  l4_port_set_entry {
    display_name      = "HZN-SVC-JMS-LEGACY-4001"
    description       = "Horizon Connection Server - JMS Legacy"
    protocol          = "TCP"
    destination_ports = ["4001"]
  }
}

resource "nsxt_policy_service" "service_hzn_jms_enhanced" {
  description  = "Horizon Connection Server - JMS Enhanced"
  display_name = "HZN-SVC-JMS-ENHANCED"

  l4_port_set_entry {
    display_name      = "HZN-SVC-JMS-ENHANCED-4002"
    description       = "Horizon Connection Server - JMS ENHANCED"
    protocol          = "TCP"
    destination_ports = ["4002"]
  }
}

resource "nsxt_policy_service" "service_hzn_jms_redundancy" {
  description  = "Horizon Connection Server - JMS Redundancy"
  display_name = "HZN-SVC-JMS-REDUNDANCY"

  l4_port_set_entry {
    display_name      = "HZN-SVC-JMS-REDUNDANCY-4100"
    description       = "Horizon Connection Server - JMS Redundancy"
    protocol          = "TCP"
    destination_ports = ["4100"]
  }
}

resource "nsxt_policy_service" "service_hzn_jms_ssl" {
  description  = "Horizon Connection Server - JMS Redundancy SSL"
  display_name = "HZN-SVC-JMS-SSL"

  l4_port_set_entry {
    display_name      = "HZN-SVC-JMS-SSL-4101"
    description       = "Horizon Connection Server - JMS Redundancy SSL"
    protocol          = "TCP"
    destination_ports = ["4101"]
  }
}

resource "nsxt_policy_service" "service_hzn_soap" {
  description  = "Horizon Connection Server to vCenter Server SOAP"
  display_name = "HZN-SVC-SOAP"

  l4_port_set_entry {
    display_name      = "HZN-SVC-SOAP-443"
    description       = "Horizon Connection Server to vCenter Server SOAP"
    protocol          = "TCP"
    destination_ports = ["443"]
  }
}

resource "nsxt_policy_service" "service_hzn_replica" {
  description  = "Horizon Connection Server Install Replica"
  display_name = "HZN-SVC-REPLICA"

  l4_port_set_entry {
    display_name      = "HZN-SVC-REPLICA-32111"
    description       = "Horizon Connection Server Install Replica"
    protocol          = "TCP"
    destination_ports = ["32111"]
  }
}

resource "nsxt_policy_service" "service_hzn_replica_ldap" {
  description  = "Horizon Connection Server Install Replica LDAP"
  display_name = "HZN-SVC-LDAP"

  l4_port_set_entry {
    display_name      = "HZN-SVC-REPLICA-LDAP-TCP-389"
    description       = "Horizon Connection Server Install Replica LDAP"
    protocol          = "TCP"
    destination_ports = ["389"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-REPLICA-LDAP-TCP-636"
    description       = "Horizon Connection Server Install Replica SLDAP"
    protocol          = "TCP"
    destination_ports = ["636"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-REPLICA-LDAP-UDP-389"
    description       = "Horizon Connection Server Install Replica LDAP"
    protocol          = "UDP"
    destination_ports = ["389"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-REPLICA-LDAP-UDP-636"
    description       = "Horizon Connection Server Install Replica SLDAP"
    protocol          = "UDP"
    destination_ports = ["636"]
  }
}

resource "nsxt_policy_service" "service_hzn_replica_ldap_gc" {
  description  = "Horizon Connection Server Install Replica LDAP GC"
  display_name = "HZN-SVC-LDAP-GC"

  l4_port_set_entry {
    display_name      = "HZN-SVC-REPLICA-LDAP-GC-TCP-3268"
    description       = "Horizon Connection Server Install Replica LDAP GC"
    protocol          = "TCP"
    destination_ports = ["3268"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-REPLICA-SLDAP-GC-TCP-3269"
    description       = "Horizon Connection Server Install Replica SLDAP GC"
    protocol          = "TCP"
    destination_ports = ["3269"]
  }
}

resource "nsxt_policy_service" "service_hzn_kerberos" {
  description  = "Horizon Connection Server to AD Kerberos"
  display_name = "HZN-SVC-CS-KERBEROS"

  l4_port_set_entry {
    display_name      = "HZN-SVC-CS-KERBEROS"
    description       = "Horizon Connection Server to AD Kerberos"
    protocol          = "TCP"
    destination_ports = ["88"]
  }
}

resource "nsxt_policy_service" "service_hzn_netbios" {
  description  = "Horizon Connection Server to Domain NetBIOS"
  display_name = "HZN-SVC-CS-NETBIOS"

  l4_port_set_entry {
    display_name      = "HZN-SVC-CS-NETBIOS-UDP"
    description       = "Horizon Connection Server to Domain NetBIOS"
    protocol          = "UDP"
    destination_ports = ["137-139"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-CS-NETBIOS-TCP"
    description       = "Horizon Connection Server to Domain NetBIOS"
    protocol          = "TCP"
    destination_ports = ["137-139"]
  }
}

resource "nsxt_policy_service" "service_hzn_dem" {
  description  = "Horizon Dynamic Environment Manager"
  display_name = "HZN-SVC-DEM"

  l4_port_set_entry {
    display_name      = "HZN-SVC-DEM-TCP"
    description       = "Horizon Dynamic Environment Manager - TCP"
    protocol          = "TCP"
    destination_ports = ["135-139"]
  }

  l4_port_set_entry {
    display_name      = "HZN-SVC-DEM-UDP"
    description       = "Horizon Dynamic Environment Manager - UDP"
    protocol          = "UDP"
    destination_ports = ["135-139"]
  }
}

resource "nsxt_policy_service" "service_hzn_dem_flex" {
  description  = "Horizon Dynamic Environment Manager Flex Engine to File Shares"
  display_name = "HZN-SVC-DEM-FLEX"

  l4_port_set_entry {
    display_name      = "HZN-SVC-DEM-FLEX"
    description       = "Horizon DEM Flex Engine"
    protocol          = "TCP"
    destination_ports = ["445"]
  }
}

resource "nsxt_policy_service" "service_hzn_alg_ms_rpc" {
  description  = "Horizon Connection Server to Connection Server MS_RPC"
  display_name = "HZN-SVC-ALG-MS_RPC"

  l4_port_set_entry {
    display_name      = "HZN-SVC-ALG-MS_RPC-135"
    description       = "Horizon Connection Server to Connection Server MS_RPC"
    protocol          = "TCP"
    destination_ports = ["135"]
  }
}

resource "nsxt_policy_service" "service_hzn_alg_ms_rpc_dynamic" {
  description  = "Horizon Connection Server to Connection Server Dynamic MS_RPC"
  display_name = "HZN-SVC-ALG-MS_RPC-DYNAMIC"

  l4_port_set_entry {
    display_name      = "HZN-SVC-ALG-MS_RPC-DYNAMIC"
    description       = "Horizon Connection Server to Connection Server Dynamic MS_RPC"
    protocol          = "TCP"
    destination_ports = ["49152-65535"]
  }
}

resource "nsxt_policy_service" "service_hzn_uag_radius" {
  description  = "Horizon UAG - RADIUS"
  display_name = "HZN-SVC-UAG-RADIUS"

  l4_port_set_entry {
    display_name      = "HZN-SVC-UAG-RADIUS-5500"
    description       = "Horizon UAG - RADIUS"
    protocol          = "UDP"
    destination_ports = ["5500"]
  }
}

resource "nsxt_policy_service" "service_hzn_app_volumes_agent" {
  description  = "Horizon App Volumes Agent"
  display_name = "HZN-SVC-APP-VOLUMES-AGENT"

  l4_port_set_entry {
    display_name      = "HZN-SVC-APP-VOLUMES-AGENT"
    description       = "Horizon App Volumes Agent"
    protocol          = "TCP"
    destination_ports = ["5985"]
  }
}

resource "nsxt_policy_service" "service_hzn_cpa_vipa" {
  description  = "Horizon Cloud Pod Architecture inter-pod VIPA"
  display_name = "HZN-SVC-CPA-VIPA"

  l4_port_set_entry {
    display_name      = "HZN-SVC-CPA-VIPA"
    description       = "Horizon Cloud Pod Architecture inter-pod VIPA"
    protocol          = "TCP"
    destination_ports = ["8472"]
  }
}

# Create Context Profiles

resource "nsxt_policy_context_profile" "cp_http" {
  display_name = "HZN-CP-HTTP"
  description  = "Horizon Context Profile for HTTP"
  app_id {
    description = "Horizon Context Profile for HTTP"
    value       = ["HTTP"]
  }
}

resource "nsxt_policy_context_profile" "cp_https" {
  display_name = "HZN-CP-HTTPS"
  description  = "Horizon Context Profile for HTTPS"
  app_id {
    description = "Horizon Context Profile for HTTPS"
    value       = ["SSL"]
  }
}

resource "nsxt_policy_context_profile" "cp_blast" {
  display_name = "HZN-CP-BLAST"
  description  = "Horizon Context Profile for BLAST"
  app_id {
    description = "Horizon Context Profile for BLAST"
    value       = ["BLAST"]
  }
}

resource "nsxt_policy_context_profile" "cp_pcoip" {
  display_name = "HZN-CP-PCOIP"
  description  = "Horizon Context Profile for PCOIP"
  app_id {
    description = "Horizon Context Profile for PCOIP"
    value       = ["PCOIP"]
  }
}

resource "nsxt_policy_context_profile" "cp_rdp" {
  display_name = "HZN-CP-RDP"
  description  = "Horizon Context Profile for RDP"
  app_id {
    description = "Horizon Context Profile for RDP"
    value       = ["RDP"]
  }
}

resource "nsxt_policy_context_profile" "cp_mssql" {
  display_name = "HZN-CP-MSSQL"
  description  = "Horizon Context Profile for MSSQL"
  app_id {
    description = "Horizon Context Profile for MSSQL"
    value       = ["MSSQL"]
  }
}

resource "nsxt_policy_context_profile" "cp_oracle" {
  display_name = "HZN-CP-ORACLE"
  description  = "Horizon Context Profile for ORACLE"
  app_id {
    description = "Horizon Context Profile for ORACLE"
    value       = ["ORACLE"]
  }
}

resource "nsxt_policy_context_profile" "cp_kerberos" {
  display_name = "HZN-CP-KERBEROS"
  description  = "Horizon Context Profile for KERBEROS"
  app_id {
    description = "Horizon Context Profile for KERBEROS"
    value       = ["KERBEROS"]
  }
}

resource "nsxt_policy_context_profile" "cp_ad" {
  display_name = "HZN-CP-ACTIVE-DIRECTORY"
  description  = "Horizon Context Profile for Active Directory"
  app_id {
    description = "Horizon Context Profile for Active Directory"
    value       = ["ACTIVDIR"]
  }
}

resource "nsxt_policy_context_profile" "cp_ldap" {
  display_name = "HZN-CP-LDAP"
  description  = "Horizon Context Profile for LDAP"
  app_id {
    description = "Horizon Context Profile for LDAP"
    value       = ["LDAP"]
  }
}

# DFW Application Category Rules

resource "nsxt_policy_security_policy" "allow_HZN" {
  display_name = "Horizon Security Policies"
  description  = "Horizon Security Policies"
  category     = "Application"
  locked       = false
  stateful     = true
  tcp_strict   = false

  rule {
    display_name       = "Load Balancer to UAG HTTPS"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.uag_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_HTTPS.path]
    #profiles           = [nsxt_policy_context_profile.cp_https.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_servers.path]
  }

  rule {
    display_name       = "Load Balancer to UAG PCoIP"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.uag_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_pcoip.path]
    #profiles           = [nsxt_policy_context_profile.cp_pcoip.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_servers.path]
  }

  rule {
    display_name       = "Load Balancer to UAG BLAST"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.uag_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_blast.path]
    #profiles           = [nsxt_policy_context_profile.cp_blast.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_servers.path]
  }

  rule {
    display_name       = "Load Balancer to Connection Server HTML Access"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_HTTPS_8443.path]
    #profiles           = [nsxt_policy_context_profile.cp_https.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Load Balancer to Connection Server HTTPS"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_HTTPS.path]
    #profiles           = [nsxt_policy_context_profile.cp_https.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Load Balancer to Horizon Agent via BLAST Extreme"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_blast_22443.path]
    #profiles           = [nsxt_policy_context_profile.cp_blast.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Load Balancer to Horizon Agent via PCoIP"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_pcoip.path]
    #profiles           = [nsxt_policy_context_profile.cp_pcoip.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Load Balancer to Horizon Agent via RDP"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_rdp.path]
    #profiles           = [nsxt_policy_context_profile.cp_rdp.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Load Balancer to Horizon Agent Client Device Redirection"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_cdr.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Load Balancer to Horizon Agent USB Redirection"
    source_groups      = [nsxt_policy_group.lb_data.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_usb.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }
 
  rule {
    display_name       = "Internal - Horizon Client to Horizon Agent via PCoIP"
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_pcoip.path]
    #profiles           = [nsxt_policy_context_profile.cp_pcoip.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Internal - Horizon Client to Horizon Agent via BLAST"
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_blast_22443.path]
    #profiles           = [nsxt_policy_context_profile.cp_blast.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Internal - Horizon Client to Horizon Agent via RDP"
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_rdp.path]
    #profiles           = [nsxt_policy_context_profile.cp_rdp.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Internal - Horizon Client to Horizon Agent Client Drive Redirection"
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_cdr.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Internal - Horizon Client to Horizon Agent USB Redirection"
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_usb.path]
    logged             = false
    scope              = [nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Internal - Browser to Connection Server HTML Access"
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_HTTPS_8443.path]
    #profiles           = [nsxt_policy_context_profile.cp_https.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Internal - Browser to Connection Server HTTP"
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_HTTP.path]
    #profiles           = [nsxt_policy_context_profile.cp_http.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Internal - Browser to Connection Server HTTPS"
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_HTTPS.path]
    #profiles           = [nsxt_policy_context_profile.cp_https.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }
  
  rule {
    display_name       = "External - Horizon Clients to UAG HTTPS"
    destination_groups = [nsxt_policy_group.uag_vip.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_HTTPS.path]
    #profiles           = [nsxt_policy_context_profile.cp_https.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_vip.path]
  }

  rule {
    display_name       = "External - Horizon Client to UAG PCoIP"
    destination_groups = [nsxt_policy_group.uag_vip.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_pcoip.path]
    #profiles           = [nsxt_policy_context_profile.cp_pcoip.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_vip.path]
  }

  rule {
    display_name       = "External - Horizon Client to UAG BLAST"
    destination_groups = [nsxt_policy_group.uag_vip.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_blast.path]
    #profiles           = [nsxt_policy_context_profile.cp_blast.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_vip.path]
  }

  rule {
    display_name       = "UAG - Horizon Client to Horizon Portal"
    source_groups      = [nsxt_policy_group.uag_servers.path]
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_HTTPS.path]
    #profiles           = [nsxt_policy_context_profile.cp_https.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_servers.path, nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "UAG - UAG to Horizon Agent via BLAST Extreme"
    source_groups      = [nsxt_policy_group.uag_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_blast_22443.path]
    #profiles           = [nsxt_policy_context_profile.cp_blast.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "UAG - UAG to Horizon Agent via PCoIP"
    source_groups      = [nsxt_policy_group.uag_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_pcoip.path]
    #profiles           = [nsxt_policy_context_profile.cp_pcoip.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "UAG - UAG to Horizon Agent via RDP"
    source_groups      = [nsxt_policy_group.uag_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_rdp.path]
    #profiles           = [nsxt_policy_context_profile.cp_rdp.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "UAG - UAG to Horizon Agent Client Device Redirection"
    source_groups      = [nsxt_policy_group.uag_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_cdr.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "UAG - UAG to Horizon Agent USB Redirection"
    source_groups      = [nsxt_policy_group.uag_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_usb.path]
    logged             = false
    scope              = [nsxt_policy_group.uag_servers.path, nsxt_policy_group.desktop_pool.path]
  }
 
  rule {
    display_name       = "Horizon CS - CS to Domain AD Services"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.ad_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_replica_ldap.path, nsxt_policy_service.service_hzn_replica_ldap_gc.path]
    #profiles           = [nsxt_policy_context_profile.cp_ldap.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.ad_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Domain RPC"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.ad_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_alg_ms_rpc.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.ad_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Domain RPC (Dynamic)"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.ad_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_alg_ms_rpc_dynamic.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.ad_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Domain SMB"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.ad_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_dem_flex.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.ad_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Domain KERBEROS"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.ad_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_kerberos.path]
    #profiles           = [nsxt_policy_context_profile.cp_kerberos.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.ad_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Domain NetBIOS"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.ad_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_netbios.path]
    #profiles           = [nsxt_policy_context_profile.cp_kerberos.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.ad_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to MSSQL DB"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.mssql_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_mssql.path]
    #profiles           = [nsxt_policy_context_profile.cp_mssql.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.mssql_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to vCenter Server"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.vcenter_server.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_HTTPS.path]
    #profiles           = [nsxt_policy_context_profile.cp_https.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Horizon Agent via BLAST Extreme"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_blast_22443.path]
    #profiles           = [nsxt_policy_context_profile.cp_blast.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Horizon Agent via PCoIP"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_pcoip.path]
    #profiles           = [nsxt_policy_context_profile.cp_pcoip.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Horizon Agent via RDP"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_rdp.path]
    #profiles           = [nsxt_policy_context_profile.cp_rdp.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Horizon Agent Client Device Redirection"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_cdr.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Horizon CS - CS to Horizon Agent USB Device Redirection"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.desktop_pool.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_usb.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name       = "Horizon CS - JMS CS to CS Legacy"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_jms_redundancy.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Horizon CS - JMS CS to CS SSL"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_jms_ssl.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to CS Replica Install"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_replica_ldap.path]
    #profiles           = [nsxt_policy_context_profile.cp_ldap.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to CS MS-RPC"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_alg_ms_rpc.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Horizon CS - CS to CS MS-RPC DYNAMIC"
    source_groups      = [nsxt_policy_group.connection_servers.path]
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_alg_ms_rpc_dynamic.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path]
  }

  rule {
    display_name       = "Horizon Desktop Pool - Pool to CS - JMS"
    source_groups      = [nsxt_policy_group.desktop_pool.path]
    destination_groups = [nsxt_policy_group.connection_servers.path]
    action             = "ALLOW"
    services           = [nsxt_policy_service.service_hzn_jms_enhanced.path, nsxt_policy_service.service_hzn_jms_legacy.path]
    logged             = false
    scope              = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.desktop_pool.path]
  }

  rule {
    display_name = "Horizon - Explicit Deny"
    action       = "REJECT"
    logged       = true
    direction    = "IN_OUT"
    ip_version   = "IPV4_IPV6"
    log_label    = "horizon-deny-all"
    scope        = [nsxt_policy_group.connection_servers.path, nsxt_policy_group.uag_servers.path]
  }
}
