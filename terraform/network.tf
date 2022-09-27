resource "azurerm_virtual_network" "vnet" {
  tags                = local.tags
  name                = lower("vnet-virtualnetwork")
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "snet" {
  for_each                                       = var.snet
  name                                           = lower("${each.value.component}")
  resource_group_name                            = azurerm_resource_group.network.name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = each.value.address_prefixes
}

resource "azurerm_network_security_group" "nsg-snet" {
  for_each            = var.snet
  resource_group_name = azurerm_resource_group.network.name
  location            = azurerm_resource_group.network.location
  name                = "nsg-${azurerm_subnet.snet[each.key].name}"
  tags                = local.tags
}


resource "azurerm_network_security_rule" "nsgrule" {
  name                        = "allowin-All-1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.nsg-snet["app"].name
}

resource "azurerm_subnet_network_security_group_association" "nsg-snet" {
  for_each                  = var.snet
  network_security_group_id = azurerm_network_security_group.nsg-snet[each.key].id
  subnet_id                 = azurerm_subnet.snet[each.key].id
}

resource "azurerm_network_watcher_flow_log" "nsgflow" {
  for_each                  = var.snet
  name                      = "NetworkWatcher_${azurerm_network_security_group.nsg-snet[each.key].name}"
  network_watcher_name      = "NetworkWatcher_WestEurope"
  resource_group_name       = "NetworkWatcherRG"
  network_security_group_id = azurerm_network_security_group.nsg-snet[each.key].id
  enabled                   = true
  storage_account_id        = azurerm_storage_account.salog.id
  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.logwkspace.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.logwkspace.location
    workspace_resource_id = azurerm_log_analytics_workspace.logwkspace.id
  }
  retention_policy {
    enabled = true
    days    = 35
  }

  tags = local.tags
}