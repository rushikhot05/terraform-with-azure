data "azurerm_resource_group" "syn-rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "syn-vnet" {
  name                = "${var.name}-vnet"
  location            = data.azurerm_resource_group.syn-rg.location
  resource_group_name = data.azurerm_resource_group.syn-rg.name
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "syn-subnet" {
  count = 2
  name                 = "${azurerm_virtual_network.syn-vnet.name}-subnet-${count.index}"
  resource_group_name  = data.azurerm_resource_group.syn-rg.name
  virtual_network_name = azurerm_virtual_network.syn-vnet.name
  address_prefixes     = ["10.10.${count.index}.0/24"]
}

resource "azurerm_public_ip" "pip" {
  count = 2
  name                = "${var.name}-pip-${count.index}"
  resource_group_name = data.azurerm_resource_group.syn-rg.name
  location            = data.azurerm_resource_group.syn-rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  count = 2
  name                = "${var.name}-nic-${count.index}"
  location            = data.azurerm_resource_group.syn-rg.location
  resource_group_name = data.azurerm_resource_group.syn-rg.name

  ip_configuration {
    name                          = "nic"
    subnet_id                     = azurerm_subnet.syn-subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "syn-server" {
  count = 2
  name                  = "${var.name}-server-${count.index}"
  resource_group_name   = data.azurerm_resource_group.syn-rg.name
  location              = data.azurerm_resource_group.syn-rg.location
  size                  = "Standard_B2s"
  admin_username        = var.admin_username != "" ? var.admin_username : "administrator"
  admin_password        = random_password.password.result
  network_interface_ids = [azurerm_network_interface.nic[count.index].id]
  os_disk {
    name                 = "syn-os-disk-${count.index}"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  disable_password_authentication = false

  provisioner "local-exec" {
    command = "echo ${self.private_ip_address} >> private_ip.txt"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  upper            = true
  lower            = true
  numeric          = true
}


# resource "null_resource" "install_apache" {
#   provisioner "remote-exec" {
#     connection {
#       host     = azurerm_linux_virtual_machine.syn-server.public_ip_address
#       user     = azurerm_linux_virtual_machine.syn-server.admin_username
#       password = random_password.password.result
#       type     = "ssh"
#     }

#     inline = [
#       "sudo apt-get update -y && sudo apt-get install -y apache2",
#       "sudo echo 'hello.. We are learning Terraform with Azure' > /var/www/html/index.html",
#       "sudo service apache2 start"
#     ]
#   }
# }

# resource "null_resource" "after-webserver" {
#   provisioner "remote-exec" {
#     connection {
#       host     = azurerm_linux_virtual_machine.syn-server.public_ip_address
#       user     = azurerm_linux_virtual_machine.syn-server.admin_username
#       password = random_password.password.result
#       type     = "ssh"
#     }

#     inline = [
#       "mkdir testdir",
#       "cd testdir && touch testfile1 testfile2 testfile3"
#     ]
#   }

#   depends_on = [
#     null_resource.install_apache
#   ]
# }