# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_workspace
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# Create a resource group on Azure with the variable name main_rg
resource "azurerm_resource_group" "ml_rg" {
  name     = "w1-test-ml-rg-1"
  location = "West Europe"

  tags = {
    zone  = "sandbox"
    owner = "yd"
    app   = "ml"
  }
}

resource "azurerm_application_insights" "ml_workspace" {
  name                = "sandbox-ml-app-insight-1"
  location            = azurerm_resource_group.ml_rg.location
  resource_group_name = azurerm_resource_group.ml_rg.name
  application_type    = "web"
  tags                = azurerm_resource_group.ml_rg.tags
}

# https://github.com/hashicorp/terraform-provider-azurerm/issues/14674
resource "azurerm_key_vault" "ml_workspace" {
  name                     = "sandboxmlkeyvault1"
  location                 = azurerm_resource_group.ml_rg.location
  resource_group_name      = azurerm_resource_group.ml_rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "standard" # "premium"
  tags                     = azurerm_resource_group.ml_rg.tags
  purge_protection_enabled = false
  # provider            = azurerm
  # soft_delete_retention_days = 7 # soft_delete_retention_days to be in the range (7 - 90)
}

resource "azurerm_storage_account" "ml_workspace" {
  name                     = "sandboxmlstorageaccount1"
  location                 = azurerm_resource_group.ml_rg.location
  resource_group_name      = azurerm_resource_group.ml_rg.name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  allow_nested_items_to_be_public = false # default is true
  tags                     = azurerm_resource_group.ml_rg.tags
}

# https://aka.ms/wsoftdelete
# recently deleted resources from the location.
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_workspace.html
resource "azurerm_machine_learning_workspace" "ml_workspace" {
  name                          = "sandbox-ml-workspace-1"
  location                      = azurerm_resource_group.ml_rg.location
  resource_group_name           = azurerm_resource_group.ml_rg.name
  application_insights_id       = azurerm_application_insights.ml_workspace.id
  key_vault_id                  = azurerm_key_vault.ml_workspace.id
  storage_account_id            = azurerm_storage_account.ml_workspace.id
  tags                          = azurerm_resource_group.ml_rg.tags
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
    zone  = "sandbox"
    owner = "yd"
    app   = "storage"
  }
}

# storage account name can only consist of lowercase letters and numbers, 
# and must be between 3 and 24 characters long
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
# cloud shell https://learn.microsoft.com/en-us/azure/cloud-shell/features
resource "azurerm_storage_account" "data_sa_1" {
  name                     = "sandboxdatastorageacct1"
  location                 = azurerm_resource_group.storage_rg_1.location
  resource_group_name      = azurerm_resource_group.storage_rg_1.name
  account_tier             = "Standard" # standard storage account
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  tags = merge(
    azurerm_resource_group.storage_rg_1.tags, 
    { "ms-resource-usage" = "azure-cloud-shell" } # add this tag for the cloud shell
  )
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
resource "azurerm_storage_share" "data_fileshare_1" {
  name                 = "sandboxcloudshellfs1"
  storage_account_name = azurerm_storage_account.data_sa_1.name
  access_tier          = "Hot"
  quota                = 10 # in GB acc_yd.img home file 5GB
  enabled_protocol     = "SMB"
  # acl {
  #   id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

  #   access_policy {
  #     permissions = "rwdl"
  #     start       = "2019-07-02T09:38:21.0000000Z"
  #     expiry      = "2019-07-02T10:38:21.0000000Z"
  #   }
  # }
  metadata = azurerm_resource_group.storage_rg_1.tags
}


# Create a Container object in the storage account
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container
resource "azurerm_storage_container" "data_container_1" {
  name                  = "data-container-1"
  storage_account_name  = azurerm_storage_account.data_sa_1.name
  container_access_type = "private" # "blob" #"private"
  metadata              = azurerm_resource_group.storage_rg_1.tags
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

# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_owner
# https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
# data "azuread_application" "current_entra_app" {
#   object_id = data.azurerm_client_config.current.client_id
# }

# output "current_entra_app" {
#   value = data.azuread_application.current_entra_app.owners
# }


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/machine_learning_compute_instance
# https://github.com/hashicorp/terraform-provider-azurerm/issues/20973#issuecomment-2093776017
# https://learn.microsoft.com/en-us/azure/virtual-machines/dv2-dsv2-series
# delete from azure ml studio -> compute instances
# Notice:
# delete the computed instance, if you don't need it.check "
# If you stop, the ci is not charged, but there is Load balancer active, you will be charged for that at AML_DEV
# https://stackoverflow.com/questions/75217339/does-azure-machine-learning-charge-for-compute-instances-even-when-they-are-stop

# resource "azurerm_machine_learning_compute_instance" "compute_instance_1" {
#   name                          = "sandbox-ml-comp-inst1"
#   machine_learning_workspace_id = azurerm_machine_learning_workspace.ml_workspace.id
#   virtual_machine_size          = "Standard_D2s_v3" # "STANDARD_DS2_V2" 
#   # authorization_type            = "personal"
#   # node_public_ip_enabled        = "false" # subnet_resource_id must be set with false
#   # ssh {
#   #   public_key = var.ssh_key
#   # }
#   # subnet_resource_id = azurerm_subnet.example.id
  
#   # TODO: edit Schedules Idle shutdown schedule 15 minutes from the details plane of compute instance in azure ml studio portal
#   # idleTimeBeforeShutdown = "PT15M"

#   description        = "sandbox compute instance 1"
#   tags = azurerm_resource_group.ml_rg.tags
#   # this will create a principal id for the compute instance
#   # identity {
#   #   type = "SystemAssigned"
#   # }

#   assign_to_user {
#     # find from the azure portal, can not be read dynamically
#     object_id = var.user_id
#     # object_id = data.azuread_client_config.current.object_id
#     # object_id = azurerm_machine_learning_workspace.ml_workspace.identity[0].principal_id
#     tenant_id = data.azurerm_client_config.current.tenant_id
#   }
# }
