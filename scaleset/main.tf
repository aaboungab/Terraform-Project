#Resource Group
resource "azurerm_resource_group" "TerraformP" {
  name     = "TP-resources"
  location = "uksouth"
}

#VNET
resource "azurerm_virtual_network" "TerraformP" {
  name                = "TP-network"
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

#VM scale set
resource "azurerm_linux_virtual_machine_scale_set" "TerraformP" {
  name                = "${var.prefix}-VMTP"
  resource_group_name = azurerm_resource_group.TerraformP.name
  location            = azurerm_resource_group.TerraformP.location
  sku                 = "Standard_F2"
  instances           = 1
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.TerraformP.id
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  lifecycle {
    ignore_changes = ["instances"]
  }
}

#Monitor Scale Set
resource "azurerm_monitor_autoscale_setting" "TerraformP" {
  name                = "Autoscale-config"
  resource_group_name = azurerm_resource_group.TerraformP.name
  location            = azurerm_resource_group.TerraformP.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.TerraformP.id

profile {
    name = "AutoScale"

    capacity {
      default = 1
      minimum = 0
      maximum = 3
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.TerraformP.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.TerraformP.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  recurrence {
      #frequency = "Week"
      timezone = "GMT Standard Time"
      days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours    = [var.in]
      minutes  = [var.inmins]
    }
  }

  profile {
    name = "Downscale"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.TerraformP.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 0
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    recurrence {
      #frequency = "Week"
      timezone = "GMT Standard Time"
      days     = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours    = [var.out]
      minutes  = [var.outmins]
    }
  }
}
