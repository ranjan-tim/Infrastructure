snet = {
  application = {
    component                                      = "ApplictaionLayer"
    address_prefixes                               = ["10.0.1.0/24"]
  }
  database = {
    component                                      = "DatabaseLayer"
    address_prefixes                               = ["10.0.1.0/24"]
  }
  appgw = {
    component                                      = "AzureApplicationGatewaySubnet"
    address_prefixes                               = ["10.0.1.0/24"]
  }
  bastion = {
    component                                      = "AzureBastionSubnet"
    address_prefixes                               = ["10.0.1.0/26"]
  }
}