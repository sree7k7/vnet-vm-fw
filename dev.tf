module "module_dev" {
  source = "./modules"
  resource_group_location = "centralindia"
  resource_group_name_prefix = "vnet-fw"
  vnet_cidr = "10.6.0.0/16"
  public_subnet_address = "10.6.1.0/24"
  gateway_subnet_address = "10.6.3.0/24"
  firewall_subnet_address_prefix = "10.6.2.0/24"
}