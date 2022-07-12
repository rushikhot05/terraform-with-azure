data "azurerm_resource_group" "syn-rg" {
  name = var.resource_group_name
}

resource "azurerm_network_security_group" "syn-nsg" {
  name                = "${var.name}-nsg"
  location            = data.azurerm_resource_group.syn-rg.location
  resource_group_name = data.azurerm_resource_group.syn-rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "all-open"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface_security_group_association" "nsg-nic-association" {
  network_interface_id      = var.network_interface_id
  network_security_group_id = azurerm_network_security_group.syn-nsg.id
}