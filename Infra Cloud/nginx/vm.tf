resource "azurerm_resource_group" "rg-lab-nginx" {
  name     = "rg-lab-nginx"
  location = "Brazil South"
}

resource "azurerm_virtual_network" "vnet-lab-nginx" {
  name                = "vnet-lab-nginx"
  location            = azurerm_resource_group.rg-lab-nginx.location
  resource_group_name = azurerm_resource_group.rg-lab-nginx.name
  address_space       = ["192.168.0.0/16"]

  tags = {
    faculdade = "Impacta"
    disciplina = "infra cloud"
    turma = "as04"
    aluno = "Rodrigo"
  }
}

resource "azurerm_subnet" "sub-internal-01" {
  name                 = "sub-internal-01"
  resource_group_name  = azurerm_resource_group.rg-lab-nginx.name
  virtual_network_name = azurerm_virtual_network.vnet-lab-nginx.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_public_ip" "ip-publico-nginx" {
  name                = "ip-publico-nginx"
  resource_group_name = azurerm_resource_group.rg-lab-nginx.name
  location            = azurerm_resource_group.rg-lab-nginx.location
  allocation_method   = "Static"

  tags = {
    faculdade = "Impacta"
    disciplina = "infra cloud"
    turma = "as04"
    aluno = "Rodrigo"
  }
}

resource "azurerm_network_security_group" "nsg-lab-nginx" {
  name                = "nsg-lab-nginx"
  location            = azurerm_resource_group.rg-lab-nginx.location
  resource_group_name = azurerm_resource_group.rg-lab-nginx.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "web"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    faculdade = "Impacta"
    disciplina = "infra cloud"
    turma = "as04"
    aluno = "Rodrigo"
  }
}

resource "azurerm_network_interface" "nic-lab-nginx" {
  name                = "nic-lab-nginx"
  location            = azurerm_resource_group.rg-lab-nginx.location
  resource_group_name = azurerm_resource_group.rg-lab-nginx.name

  ip_configuration {
    name                            = "ip-lab-nginx"
    subnet_id                       = azurerm_subnet.sub-internal-01.id
    private_ip_address_allocation   = "Dynamic"
    public_ip_address_id            = azurerm_public_ip.ip-publico-nginx.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic-nsg-nginx" {
  network_interface_id      = azurerm_network_interface.nic-lab-nginx.id
  network_security_group_id = azurerm_network_security_group.nsg-lab-nginx.id
}

resource "azurerm_virtual_machine" "vm-lab-nginx" {
  name                  = "vm-lab-nginx"
  location              = azurerm_resource_group.rg-lab-nginx.location
  resource_group_name   = azurerm_resource_group.rg-lab-nginx.name
  network_interface_ids = [azurerm_network_interface.nic-lab-nginx.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "vm-lab-nginx"
    admin_username = "adminUsername"
    admin_password = var.pwd_user
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
  
  tags = {
    faculdade = "Impacta"
    disciplina = "infra cloud"
    turma = "as04"
    aluno = "Rodrigo"
  }
}
