terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.13.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
}

provider "random" {

}

provider "null" {

}

module "create-vm" {
  source         = "./modules/vm"
  admin_username = "rushi"
  name           = "synechron"
}

# module "security-group" {
#   source               = "./modules/sg"
#   name                 = "synechron"
#   network_interface_id = module.create-vm.nic-id
# }

output "public-ip" {
  value = module.create-vm.linux_public_ip
}

output "for-loop-public-ip" {
  value = module.create-vm.public_ip_using_for_loop
}

output "password" {
  value     = module.create-vm.server_password
  sensitive = true
}