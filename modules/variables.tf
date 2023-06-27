variable "resource_group_location" {
  default     = "westeurope"
}

variable "resource_group_name_prefix" {
  default     = "vnet-fw"
}

# Vnet details
variable "vnet_config" {
    type = map(string)
    default = {
      vnetname = "fw-vnet"
      public_subnet = "SubnetA"      
      azure_firewall_subnet = "AzureFirewallSubnet"       
    }
}
variable "vnet_cidr" {
    type = string
#   default = ["10.7.0.0/16"]
}
variable "public_subnet_address" {
    type = string
#   default = ["10.7.1.0/24"]
}
variable "gateway_subnet_address" {
    type = string
#   default = ["10.7.3.0/24"]
}
variable "firewall_subnet_address_prefix" {
    type = string
#   default = ["10.7.4.128/25"]
}

variable "firewall_service_endpoints" {
  description = "Service endpoints to add to the firewall subnet"
  type        = list(string)
  default = [
    "Microsoft.AzureActiveDirectory",
    "Microsoft.AzureCosmosDB",
    "Microsoft.EventHub",
    "Microsoft.KeyVault",
    "Microsoft.ServiceBus",
    "Microsoft.Sql",
    "Microsoft.Storage",
  ]
}