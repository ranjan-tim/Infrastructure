

resource "azurerm_public_ip" "appgw-pubip" {
  name                = lower("pip-appgw")
  allocation_method   = "Static"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  sku                 = "Standard"
  availability_zone   = "No-Zone"

}

resource "azurerm_dns_a_record" "appgw-record" {
  name                = "test"
  zone_name           = azurerm_dns_zone.example.name
  resource_group_name = azurerm_resource_group.app.name
  ttl                 = 300
  records             = ["10.0.180.17"]
}

resource "azurerm_application_gateway" "appgw" {
  name = lower("appgw-applicationgateway")
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location

  sku {
    name     = var.appgw-sku-name
    tier     = var.appgw-sku-tier
    capacity = var.appgw-sku-capacity
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20170401S"
  }

  gateway_ip_configuration {
    subnet_id = azurerm_subnet.snet-appgw.id
    name      = lower("appgw-config")
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    private_ip_address   = cidrhost(azurerm_subnet.snet-appgw.address_prefix, var.host_num)
    public_ip_address_id = azurerm_public_ip.appgw-pubip.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  backend_http_settings {
    cookie_based_affinity = "Disabled"
    name                  = local.http_setting_name
    port                  = 80
    protocol              = "Http"

  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    http_listener_name         = local.listener_name
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    backend_http_settings_name = local.http_setting_name
    backend_address_pool_name  = local.backend_address_pool_name
  }

  enable_http2 = true
}

resource "azurerm_app_service_plan" "asp" {
  name                = "asp-appserviceplan"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "as" {
  name                = "as-app-service"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  app_service_plan_id = azurerm_app_service_plan.app.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}