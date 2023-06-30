output "firewall_private_ip" {
  value = azurerm_firewall.azure_fw.private_ip_ranges
}