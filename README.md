# IaC-example
Azure examples of using terraform for multi cloud IaC

This repository contains terraform code for Azure Cloud with Azure Provider to create:
* Azure ML Studio workspace
* Storage Account with 
    * Blob Storage
    * File Share
* Azure ML Datastore (Azure Blobstore)


## Setting up Terraform project
.tfstate file holds all the configurations of the cloud infrastructure that has been created.
It should never be uploaded to the git repository

### .gitignore the .tfstate

# Reference
* Setup VS code with HCL project: https://medium.com/nerd-for-tech/how-to-auto-format-hcl-terraform-code-in-visual-studio-code-6fa0e7afbb5e
* .tfstate Terraform state file: https://linumary.medium.com/terraform-and-its-state-file-concept-d411d48fefbc

## Install terraform on Mac
```shell
brew list terraform
brew install terraform
brew upgrade terraform
```
Reference:
* https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build

## Install Azure CLI on Mac
```shell
brew update && brew install azure-cli
az login
```
Reference:
* https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-macos
* https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret

## init terraform
```shell
# init terraform state
terraform init
# plan the change shall be made to your cloud resources
terraform plan
# executed planed changes defined by HCL 
terraform apply
```

## Apply terraform
terraform will take the variables from either `terraform.tfvars` or `.auto.tfvars`

Otherwise, we need to define the .tfvars file during the terraform apply.
```shell
terraform apply -var-file="const.tfvars"
```

## Visualize your terraform plan
```shell
terraform graph -type=plan | dot -Tpng -o graph.png
```

## Upgrade to new provider version
```shell
terraform init -upgrade
```
* https://developer.hashicorp.com/terraform/language/expressions/version-constraints

## Destroy
```shell
terraform plan -destroy
terraform apply -destroy
```
* https://developer.hashicorp.com/terraform/cli/commands/destroy

## Learning Source
* Get started with Azure: https://developer.hashicorp.com/terraform/tutorials/azure-get-started
* Get started with GCP: https://developer.hashicorp.com/terraform/tutorials/gcp-get-started
* Visualize your terraform plan: https://medium.com/vmacwrites/tools-to-visualize-your-terraform-plan-d421c6255f9f
