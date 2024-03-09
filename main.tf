variable "subscription_id" {
    description = "The subscription ID for the service principal"
    type        = string
}

variable "client_id" {
    description = "The client ID for the service principal"
    type        = string
}

variable "client_secret" {
    description = "The client secret for the service principal"
    type        = string
}

variable "tenant_id" {
    description = "The tenant ID for the service principal"
    type        = string
}

variable "my_val" {
    description = "The client ID for the service principal"
    type        = string
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
# using the environment variables instead of the variables directly
provider "azurerm" {
  features {}
}

# provider "azurerm" {
#     subscription_id = var.subscription_id
#     client_id       = var.client_id
#     client_secret   = var.client_secret
#     tenant_id       = var.tenant_id
#   features {}
# }

resource "azurerm_resource_group" "main_rg" {
  name     = "w1-test-ml-rg"
  location = "West Europe"

  tags = {
    zone = "sandbox"
    owner = "yd"
    app = "ml"
  }
}