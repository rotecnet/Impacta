data "azurerm_public_ip" "data-publicip" {
  name = azurerm_public_ip.ip-publico-nginx.name
  resource_group_name = azurerm_resource_group.rg-lab-nginx.name
}

resource "null_resource" "install-nginx" {
  triggers = {
    order = azurerm_virtual_machine.vm-lab-nginx.id
  }

  connection {
    type = "ssh"
    host = data.azurerm_public_ip.data-publicip.ip_address
    user = "adminUsername"
    password = var.pwd_user
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y nginx"
    ]
  }

  depends_on = [
    azurerm_virtual_machine.vm-lab-nginx
  ]
}
