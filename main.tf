resource "azurerm_resource_group" "testrg" {
  name     = "testrg"
  location = "westus"
}

resource "azurerm_virtual_network" "test-vnet" {
  name                = "test-vnet"
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "test-subnet" {
  name                 = "test-subnet"
  resource_group_name  = azurerm_resource_group.testrg.name
  virtual_network_name = azurerm_virtual_network.test-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "test-public-ip" {
  name                = "test-public-ip"
  resource_group_name = azurerm_resource_group.testrg.name
  location            = azurerm_resource_group.testrg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "test-nic" {
  name                = "test-nic"
  location            = azurerm_resource_group.testrg.location
  resource_group_name = azurerm_resource_group.testrg.name
  ip_configuration {
    name                          = "test-ip"
    subnet_id                     = azurerm_subnet.test-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test-public-ip.id
  }
}



resource "azurerm_virtual_machine" "test-vm" {
  name                  = "test-vm"
  location              = azurerm_resource_group.testrg.location
  resource_group_name   = azurerm_resource_group.testrg.name
  network_interface_ids = [azurerm_network_interface.test-nic.id]
  vm_size               = "Standard_D2s_v3"
  os_profile_windows_config {
    timezone = "Central Standard Time"
  }
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"

  }
  storage_os_disk {
    name              = "test-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "test-vm"
    admin_username = "test-vm"
    admin_password = "Password1234!"
  }
  tags = {
    "Environment" = "Test"
  }

}