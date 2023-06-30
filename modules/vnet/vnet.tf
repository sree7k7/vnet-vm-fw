
# Create Resource Group
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name_prefix
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_config["vnetname"]
  address_space       = ["${var.vnet_cidr}"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name_prefix
}

# Create public subnet
resource "azurerm_subnet" "vnet_public_subnet" {
  name                 = var.vnet_config["public_subnet"]
  resource_group_name  = var.resource_group_name_prefix
  
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.public_subnet_address}"]
  
}

# Create firewall subnet
resource "azurerm_subnet" "firewall_subnet" {
  name                 = var.vnet_config["azure_firewall_subnet"]
  resource_group_name  = var.resource_group_name_prefix
  
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.firewall_subnet_address_prefix}"]
  
}

## Fire will route table

# resource "azurerm_route_table" "firewall_route_table" {
#   name                = "azure_firewall-routetable"
#   location = var.resource_group_location
#   resource_group_name  = var.resource_group_name_prefix

#   route {
#     name                   = "internetDeny"
#     address_prefix         = "0.0.0.0/0"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = var.firwall_private_ip
#   }
# }

# resource "azurerm_subnet_route_table_association" "example" {
#   subnet_id      = azurerm_subnet.example.id
#   route_table_id = azurerm_route_table.example.id
# }