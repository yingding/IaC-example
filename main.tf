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

provider "azurerm" {
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
  features {}
}