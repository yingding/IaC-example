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

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_workspace
data "azurerm_client_config" "current" {}

# Create a resource group on Azure with the variable name main_rg
resource "azurerm_resource_group" "ml_rg" {
  name     = "w1-test-ml-rg-1"
  location = "West Europe"

  tags = {
    zone = "sandbox"
    owner = "yd"
    app = "ml"
  }
}

resource "azurerm_application_insights" "ml_workspace" {
  name                = "sandbox-ml-app-insight-1"
  location            = azurerm_resource_group.ml_rg.location
  resource_group_name = azurerm_resource_group.ml_rg.name
  application_type    = "web"
  tags = azurerm_resource_group.ml_rg.tags 
}

resource "azurerm_key_vault" "ml_workspace" {
  name                = "sandboxmlkeyvault1"
  location            = azurerm_resource_group.ml_rg.location
  resource_group_name = azurerm_resource_group.ml_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard" # "premium"
  tags = azurerm_resource_group.ml_rg.tags 
}

resource "azurerm_storage_account" "ml_workspace" {
  name                     = "sandboxmlstorageaccount1"
  location                 = azurerm_resource_group.ml_rg.location
  resource_group_name      = azurerm_resource_group.ml_rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = azurerm_resource_group.ml_rg.tags 
}

resource "azurerm_machine_learning_workspace" "ml_workspace" {
  name                    = "sandbox-ml-workspace-1"
  location                = azurerm_resource_group.ml_rg.location
  resource_group_name     = azurerm_resource_group.ml_rg.name
  application_insights_id = azurerm_application_insights.ml_workspace.id
  key_vault_id            = azurerm_key_vault.ml_workspace.id
  storage_account_id      = azurerm_storage_account.ml_workspace.id
  tags = azurerm_resource_group.ml_rg.tags 

  identity {
    type = "SystemAssigned"
  }
}