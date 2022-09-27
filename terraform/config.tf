provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0" 
    }
  }
  backend "azurerm" {
    
  }
}
