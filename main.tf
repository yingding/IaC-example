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

# https://developer.hashicorp.com/terraform/language/expressions/version-constraints
# allows only the rightmost version component to increment ~> 3.101.0
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.101.0" # "~>3.0.0" 
    }
  }
}

# Configure the Microsoft Azure Provider
# using the environment variables instead of the variables directly
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/features-block
# https://github.com/hashicorp/terraform-provider-azurerm/pull/25624
provider "azurerm" {
  features {
    machine_learning {
      # remove the soft delete azure machine learning workspace
      purge_soft_deleted_workspace_on_destroy = true
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


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

# https://github.com/hashicorp/terraform-provider-azurerm/issues/14674
resource "azurerm_key_vault" "ml_workspace" {
  name                = "sandboxmlkeyvault1"
  location            = azurerm_resource_group.ml_rg.location
  resource_group_name = azurerm_resource_group.ml_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard" # "premium"
  tags = azurerm_resource_group.ml_rg.tags
  purge_protection_enabled   = false
  # provider            = azurerm
  # soft_delete_retention_days = 7 # soft_delete_retention_days to be in the range (7 - 90)
}

resource "azurerm_storage_account" "ml_workspace" {
  name                     = "sandboxmlstorageaccount1"
  location                 = azurerm_resource_group.ml_rg.location
  resource_group_name      = azurerm_resource_group.ml_rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = azurerm_resource_group.ml_rg.tags 
}

# https://aka.ms/wsoftdelete
# recently deleted resources from the location.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_workspace.html
resource "azurerm_machine_learning_workspace" "ml_workspace" {
  name                    = "sandbox-ml-workspace-1"
  location                = azurerm_resource_group.ml_rg.location
  resource_group_name     = azurerm_resource_group.ml_rg.name
  application_insights_id = azurerm_application_insights.ml_workspace.id
  key_vault_id            = azurerm_key_vault.ml_workspace.id
  storage_account_id      = azurerm_storage_account.ml_workspace.id
  tags = azurerm_resource_group.ml_rg.tags
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

## Create a resource group on Azure with the variable name storage_rg_1 for storing sandbox data
resource "azurerm_resource_group" "storage_rg_1" {
  name     = "w1-test-data-rg-1"
  location = "West Europe"

  tags = {
    zone = "sandbox"
    owner = "yd"
    app = "storage"
  }
}

# storage account name can only consist of lowercase letters and numbers, 
# and must be between 3 and 24 characters long
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "data_sa_1" {
  name                     = "sandboxdatastorageacct1"
  location                 = azurerm_resource_group.storage_rg_1.location
  resource_group_name      = azurerm_resource_group.storage_rg_1.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags = azurerm_resource_group.storage_rg_1.tags 
}

# Create a Container object in the storage account
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container
resource "azurerm_storage_container" "data_container_1" {
  name                  = "data-container-1"
  storage_account_name  = azurerm_storage_account.data_sa_1.name
  container_access_type = "private" # "blob" #"private"
  metadata = azurerm_resource_group.storage_rg_1.tags
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_datastore_blobstorage
# https://learn.microsoft.com/en-us/azure/templates/microsoft.machinelearningservices/workspaces/datastores?pivots=deployment-language-bicep
resource "azurerm_machine_learning_datastore_blobstorage" "ml_blobstorage_1" {
  name                 = "azureblob_datastore_1"
  workspace_id         = azurerm_machine_learning_workspace.ml_workspace.id 
  storage_container_id = azurerm_storage_container.data_container_1.resource_manager_id
  account_key          = azurerm_storage_account.data_sa_1.primary_access_key # access key of the storage account
  # shared_access_signature = {
  #   expiry = "2023-12-31T00:00:00Z"
  #   permissions = ["read", "write", "delete", "list"]
  # }
  tags = azurerm_resource_group.storage_rg_1.tags 
}