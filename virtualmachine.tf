################
##networkinterface
###############

resource "azurerm_network_interface" "kashnic" {
  count                          = var.number_of_machines  
  name                           = "kashnic${count.index}"
  location                       = local.location
  resource_group_name            = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnets[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.kashpip[count.index].id
  }
  depends_on = [
     azurerm_subnet.subnets,
     azurerm_public_ip.kashpip
   ]
}



##############
## Public Ip address
##################

resource "azurerm_public_ip" "kashpip" {
  count               = var.number_of_machines
  name                = "kashpip${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  depends_on = [ 
        azurerm_resource_group.terraformrg
     ]
}


###########
## virtual machine
#######


resource "azurerm_windows_virtual_machine" "kashvm" {
  count               = var.number_of_machines
  name                = "kashvm${count.index}"
  resource_group_name = local.resource_group_name
  location            = local.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.kashnic[count.index].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  depends_on = [ azurerm_virtual_network.terraformvnet,
                 azurerm_network_interface.kashnic
  
   ]
}