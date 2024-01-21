# IaC-example
examples of using terraform for multi cloud IaC

## Setting up Terraform project
.tfstate file holds all the configurations of the cloud infrastructure that has been created.
It should never be uploaded to the git repository

### .gitignore the .tfstate

# Reference
* Setup VS code with HCL project: https://medium.com/nerd-for-tech/how-to-auto-format-hcl-terraform-code-in-visual-studio-code-6fa0e7afbb5e
* .tfstate Terraform state file: https://linumary.medium.com/terraform-and-its-state-file-concept-d411d48fefbc

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

## Learning Source
* Get started with Azure: https://developer.hashicorp.com/terraform/tutorials/azure-get-started
* Get started with GCP: https://developer.hashicorp.com/terraform/tutorials/gcp-get-started
* Visualize your terraform plan: https://medium.com/vmacwrites/tools-to-visualize-your-terraform-plan-d421c6255f9f
