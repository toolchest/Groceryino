variable "subcription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "location" { default = "eastus" }
variable "username" { default = "adminuser" }
variable "password" { default = "reallybadpassword" }
variable "bla" {default = "charles"}


provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}


resource "azurerm_virtual_network" "test" {
  name                = "test"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
}
 
resource "azurerm_subnet" "test" {
  name                 = "test"
  resource_group_name  = "${azurerm_resource_group.test.name}"
  virtual_network_name = "${azurerm_virtual_network.test.name}"
  address_prefix       = "10.0.2.0/24"
}
 
resource "azurerm_network_interface" "test" {
  name                = "test"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.test.id}"
    private_ip_address_allocation = "dynamic"
  }
}
 
resource "azurerm_storage_account" "test" {
  name                = "somename"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_type        = "Standard_LRS"
}
 
resource "azurerm_storage_container" "test" {
  name                  = "helloworld"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  storage_account_name  = "${azurerm_storage_account.test.name}"
  container_access_type = "private"
}
 
resource "azurerm_virtual_machine" "test" {
  name                  = "TestVM01"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.test.name}"
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  vm_size               = "Standard_A0"
 
  storage_image_reference {
    publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
  }
 
  storage_os_disk {
    name          = "myosdisk1"
    vhd_uri       = "${azurerm_storage_account.test.primary_blob_endpoint}${azurerm_storage_container.test.name}/myosdisk1.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }
 
  os_profile {
    computer_name  = "TestVM01"
    admin_username = "${var.username}"
	admin_password = "reallybadpassword"
  }
  
  os_profile_linux_config {
        disable_password_authentication = false
		}
}
