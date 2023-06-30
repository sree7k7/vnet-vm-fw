output "subnet_id" {
  value = azurerm_subnet.vnet_public_subnet.id
}



output "firewallSubnet" {
  value = azurerm_subnet.firewall_subnet.id
}

