#Azure as provider
provider "azurerm" {
  features {}
}
#Resource Group
resource "azurerm_resource_group" "TerraformP" {
  name     = "TP-resources"
  location = "uksouth"
}
#VNET
resource "azurerm_virtual_network" "TerraformP" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.TerraformP.location
  resource_group_name = azurerm_resource_group.TerraformP.name
}
#Subnet
resource "azurerm_subnet" "TerraformP" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.TerraformP.name
  virtual_network_name = azurerm_virtual_network.TerraformP.name
  address_prefixes     = ["10.0.2.0/24"]
}
#Network interface
resource "azurerm_network_interface" "TerraformP" {
  name                = "TPnic"
  location            = azurerm_resource_group.TerraformP.location
  resource_group_name = azurerm_resource_group.TerraformP.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.TerraformP.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.TerraformP.id
  }
}
#Virtual Machine
resource "azurerm_linux_virtual_machine" "TerraformP" {
  name                = var.name
  resource_group_name = azurerm_resource_group.TerraformP.name
  location            = azurerm_resource_group.TerraformP.location
  size                = var.size
  admin_username      = var.adminuser
  network_interface_ids = [
    azurerm_network_interface.TerraformP.id,
  ]
  virtual_machine_scale_set_id = azurerm_virtual_machine_scale_set.TerraformP.id  

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/aboun/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
#PublicIP
resource "azurerm_public_ip" "TerraformP" {
  name                = "PublicIp"
  resource_group_name = azurerm_resource_group.TerraformP.name
  location            = azurerm_resource_group.TerraformP.location
  allocation_method   = "Static"
}
#VM scale set
resource "azurerm_virtual_machine_scale_set" "TerraformP" {
  name                = "mytestscaleset-1"
  location            = azurerm_resource_group.TerraformP.location
  resource_group_name = azurerm_resource_group.TerraformP.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "testvm"
    admin_username       = "myadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/myadmin/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.TerraformP.id
    }
  }
}

#Network Security Group
resource "azurerm_network_security_group" "TerraformP" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.TerraformP.location
  resource_group_name = azurerm_resource_group.TerraformP.name

  security_rule {
    name                       = "ssh-allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#NISG Association
resource "azurerm_network_interface_security_group_association" "TerraformP" {
  network_interface_id      = azurerm_network_interface.TerraformP.id
  network_security_group_id = azurerm_network_security_group.TerraformP.id
}