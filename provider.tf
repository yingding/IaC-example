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

variable "user_id" {
  description = "The user ID for the microsoft entra user"
  type        = string
}

# https://developer.hashicorp.com/terraform/language/expressions/version-constraints
# allows only the rightmost version component to increment ~> 3.101.0
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.105.0" # "~> 3.102.0" "~>3.0.0" 
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.50.0"# "~> 2.48.0"
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