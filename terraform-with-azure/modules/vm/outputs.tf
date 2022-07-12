output "linux_public_ip" {
  value = azurerm_linux_virtual_machine.syn-server.*.public_ip_address
}

output "public_ip_using_for_loop" {
  value = [
    for syn-server in azurerm_linux_virtual_machine.syn-server : syn-server.public_ip_address
  ]
}

output "server_password" {
  value     = random_password.password.result
  sensitive = true
}

# output "nic-id" {
#   value = azurerm_network_interface.nic.id
# }