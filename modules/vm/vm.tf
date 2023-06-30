# Create vm public IPs
resource "azurerm_public_ip" "vm_public_ip" {
  name                = "PublicIp"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name_prefix
  allocation_method   = "Dynamic"
}
# Create network interface
resource "azurerm_network_interface" "vm_public_nic" {
  name                = "NIC"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name_prefix

  ip_configuration {
    name                          = "nic_configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

# Associate NSG to public-subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg_association" {
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.public_sg.id
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "${var.resource_group_location}-Vm"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name_prefix
  network_interface_ids = [azurerm_network_interface.vm_public_nic.id]
  size                  = "Standard_DS1_v2"
  admin_username                  = "demousr"
  admin_password                  = "Password@123"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.vm.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.9"
  auto_upgrade_minor_version = true
  settings = <<SETTINGS
    {
        "commandToExecute":"powershell -ExecutionPolicy Unrestricted Add-WindowsFeature Web-Server; powershell -ExecutionPolicy Unrestricted Add-Content -Path \"C:\\inetpub\\wwwroot\\Default.html\" -Value $($env:computername)"
    }
SETTINGS
}

## Create Network Security Group and rule
resource "azurerm_network_security_group" "public_sg" {
  name                = "SecurityGroup"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name_prefix

  security_rule {
    name                       = "InternetAccess"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RDP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
