resource "azurerm_resource_group" "network" {
  name     = lower("rg-network-1")
  location = "West Europe"

  tags = local.tags
}

resource "azurerm_resource_group" "app" {
  name     = lower("rg-application-1")
  location = "West Europe"

  tags = local.tags
}

resource "azurerm_resource_group" "log" {
  name     = lower("rg-log-1")
  location = "West Europe"

  tags = local.tags
}

resource "azurerm_resource_group" "db" {
  name     = lower("rg-database-1")
  location = "West Europe"

  tags = local.tags
}

resource "azurerm_log_analytics_workspace" "logwkspace" {
  resource_group_name = azurerm_resource_group.log.name
  location            = azurerm_resource_group.log.location
  name                = lower("log-logwkspace")
  sku                 = "PerGB2018"
  retention_in_days   = 90

  tags = local.tags
}

resource "azurerm_application_insights" "ai" {
  resource_group_name = azurerm_resource_group.log.name
  location            = azurerm_resource_group.log.location
  name                = lower("ai-applicationinsights")
  workspace_id        = azurerm_log_analytics_workspace.logwkspace.id
  application_type    = "web"

  tags = local.tags
}

resource "azurerm_storage_account" "salog" {
  resource_group_name = azurerm_resource_group.log.name
  location            = azurerm_resource_group.log.location
  name                = lower("salog")

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  allow_blob_public_access  = false

  tags = local.tags
}

resource "azurerm_storage_account_network_rules" "salogrules" {
  default_action     = "Deny"
  bypass             = ["AzureServices", "Logging", "Metrics"]
  storage_account_id = azurerm_storage_account.salog.id

}

resource "azurerm_key_vault" "kv" {
  name                            = lower("kv-keyvault")
  resource_group_name             = azurerm_resource_group.app.name
  location                        = azurerm_resource_group.app.location
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = true
  sku_name                        = "standard"
  purge_protection_enabled        = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id

  tags = local.tags
}

resource "azurerm_network_interface" "vm" {
  name                = "vm-nic"
  location            = azurerm_resource_group.log.location
  resource_group_name = azurerm_resource_group.log.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-machine"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
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
}

resource "azurerm_dns_zone" "dns" {
  name                = "mydomain.com"
  resource_group_name = azurerm_resource_group.app.name
}

resource "azurerm_public_ip" "bastion_ip" {
  name                = "pip-bast"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.tags
}

resource "azurerm_bastion_host" "bastion_host" {
  name                = "bast-westeurope"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnetbastion.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }

  tags = local.tags
}
