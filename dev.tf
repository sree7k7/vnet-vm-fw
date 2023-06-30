variable "resource_group_location" {
  type = string
  default     = "westeurope"
}

variable "resource_group_name_prefix" {
  default     = "vnet-fw"
}


module "vnet" {
  source = "./modules/vnet"
  vnet_cidr = "10.6.0.0/16"
  public_subnet_address = "10.6.1.0/24"
  gateway_subnet_address = "10.6.3.0/24"
  firewall_subnet_address_prefix = "10.6.2.0/24"
}


module "vm_windows" {
  source = "./modules/vm"
  subnet_id = module.vnet.subnet_id
}

module "firewall" {
  source = "./modules/firewall"
  firewall_subnet_id = module.vnet.firewallSubnet
  vm_private_ip = module.vm_windows.vm_private_ip
  ruleName = "allow_rdp"
  protocol = "TCP"
  source_address = "83.221.156.201"
  # destination_address = firewall ip internal
  destination_port = "4000"
  translated_port = 3389
}