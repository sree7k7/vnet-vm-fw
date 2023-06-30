resource "azurerm_public_ip" "fw-pip" {
  # for_each            = local.public_ip_map
  name                = "fw_pip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name_prefix
  allocation_method   = "Static"
  sku                 = "Standard"
  # public_ip_prefix_id = azurerm_public_ip_prefix.pip_prefix.id
}
resource "azurerm_firewall_policy" "firewall_policy" {
  name                = "firewall_policy"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name_prefix
}

resource "azurerm_firewall" "azure_fw" {
  name                = lower("azureFW-${var.resource_group_location}")
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name_prefix
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  threat_intel_mode   = "Alert"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.fw-pip.id
  }
}

# #----------------------------------------------
# # Azure Firewall Network/Application/NAT Rules 
# #----------------------------------------------

resource "azurerm_firewall_policy_rule_collection_group" "example" {
  name               = "example-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  priority           = 500

  nat_rule_collection {
    name     = "nat_rule_collection1"
    priority = 300
    action   = "Dnat"
    rule {
      name                  = var.ruleName
      protocols             = [var.protocol] 
      source_addresses      = [var.source_address]
      destination_address   = azurerm_public_ip.fw-pip.ip_address
      destination_ports     = [var.destination_port]
      translated_address    = var.vm_private_ip
      translated_port       = var.translated_port
    }
#   rule {
#     name                  = "local-rdp-rule"
#     source_addresses      = ["83.221.156.201",]
#     destination_ports     = ["4000"]
#     destination_addresses = [azurerm_public_ip.fw-pip.ip_address]
#     protocols             = ["TCP",]
#     translated_address    = azurerm_windows_virtual_machine.vm.private_ip_address
#     translated_port       = 3389
#   }
  }

}


## Fire will route table

resource "azurerm_route_table" "firewall_route_table" {
  name                = "azure_firewall-routetable"
  location = var.resource_group_location
  resource_group_name  = var.resource_group_name_prefix

  route {
    name                   = "internetDeny"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.azure_fw.ip_configuration[0].private_ip_address
  }
}

# resource "azurerm_subnet_route_table_association" "example" {
#   subnet_id      = var.firewall_subnet_id
#   route_table_id = azurerm_route_table.firewall_route_table.id
# }