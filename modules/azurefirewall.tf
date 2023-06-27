resource "azurerm_public_ip" "fw-pip" {
  # for_each            = local.public_ip_map
  name                = "fw_pip"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  # public_ip_prefix_id = azurerm_public_ip_prefix.pip_prefix.id
}
resource "azurerm_firewall_policy" "firewall_policy" {
  name                = "firewall_policy"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_firewall" "azure_fw" {
  name                = lower("azureFW-${var.vnet_config["vnetname"]}-${var.resource_group_location}")
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  threat_intel_mode   = "Alert"
  firewall_policy_id = azurerm_firewall_policy.firewall_policy.id
  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = azurerm_subnet.firewall_subnet.id
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
      name                  = "nat_rule_collection1_rule1"
      protocols             = ["TCP"]
      source_addresses      = ["83.221.156.201"]
      destination_address   = azurerm_public_ip.fw-pip.ip_address
      destination_ports     = ["4000"]
      translated_address    = azurerm_windows_virtual_machine.vm.private_ip_address
      translated_port       = 3389
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
#   lifecycle {
#     ignore_changes = [ ]
# }
}
