output "vm_private_ip" {
  value = azurerm_windows_virtual_machine.vm.private_ip_address
}

# output "vm_nsg" {
#   value = azurerm_network_security_group.public_nsg
# }


