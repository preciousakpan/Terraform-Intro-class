terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.61.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
}


resource "azurerm_resource_group" "prg" {
  name     = "example-resources"
  location = "Uk South"
}

resource "azurerm_virtual_network" "pvnet" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.prg.location
  resource_group_name = azurerm_resource_group.prg.name
}

resource "azurerm_subnet" "psnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.prg.name
  virtual_network_name = azurerm_virtual_network.pvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "ppip" {
  name                    = "tester-pip"
  location                = azurerm_resource_group.prg.location
  resource_group_name     = azurerm_resource_group.prg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "test"
  }
}

resource "azurerm_network_interface" "pnic" {
  name                = "example-nic"
  location            = azurerm_resource_group.prg.location
  resource_group_name = azurerm_resource_group.prg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.psnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.6"
    public_ip_address_id          = azurerm_public_ip.ppip.id
  }
}

resource "azurerm_linux_virtual_machine" "pvm" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.prg.name
  location            = azurerm_resource_group.prg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.pnic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "pnsg" {
  name                = "example-nsg"
  location            = azurerm_resource_group.prg.location
  resource_group_name = azurerm_resource_group.prg.name

  security_rule {
    name                       = "p22"
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
    name                       = "p8000"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                        = "p80"
    priority                    = 201
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }

}

resource "azurerm_subnet_network_security_group_association" "pnsga" {
  subnet_id                 = azurerm_subnet.psnet.id
  network_security_group_id = azurerm_network_security_group.pnsg.id
}

# resource "azurerm_network_security_rule" "example" {
#   name                        = "p80"
#   priority                    = 201
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "Tcp"
#   source_port_range           = "*"
#   destination_port_range      = "80"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.prg.name
#   network_security_group_name = azurerm_network_security_group.pnsg.name
# }


resource "azurerm_subnet" "psnet2" {
  name                 = "internal2"
  resource_group_name  = azurerm_resource_group.prg.name
  virtual_network_name = azurerm_virtual_network.pvnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "ppip2" {
  name                    = "tester-pip2"
  location                = azurerm_resource_group.prg.location
  resource_group_name     = azurerm_resource_group.prg.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "test"
  }
}

resource "azurerm_network_interface" "pnic2" {
  name                = "example-nic2"
  location            = azurerm_resource_group.prg.location
  resource_group_name = azurerm_resource_group.prg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.psnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.1"
    public_ip_address_id          = azurerm_public_ip.ppip2.id
  }
}

resource "azurerm_linux_virtual_machine" "pvm2" {
  name                = "example-machine2"
  resource_group_name = azurerm_resource_group.prg.name
  location            = azurerm_resource_group.prg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.pnic2.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

resource "azurerm_network_security_group" "pnsg2" {
  name                = "example-nsg2"
  location            = azurerm_resource_group.prg.location
  resource_group_name = azurerm_resource_group.prg.name


}

resource "azurerm_subnet_network_security_group_association" "pnsga2" {
  subnet_id                 = azurerm_subnet.psnet2.id
  network_security_group_id = azurerm_network_security_group.pnsg2.id
}

resource "azurerm_network_security_rule" "example2" {
  name                        = "p22"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.prg.name
  network_security_group_name = azurerm_network_security_group.pnsg2.name
}


resource "azurerm_network_security_rule" "example3" {
  name                        = "p5432"
  priority                    = 201
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.prg.name
  network_security_group_name = azurerm_network_security_group.pnsg2.name
}


output "public_ip1" {
  value = azurerm_public_ip.ppip.ip_address
}

output "public_ip2" {
  value = azurerm_public_ip.ppip2.ip_address
}

output "private_ip1" {
  value = azurerm_network_interface.pnic.private_ip_address
}

output "private_ip2" {
  value = azurerm_network_interface.pnic2.private_ip_address
}
