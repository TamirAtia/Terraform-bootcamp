
# Terraform-bootcamp
![image](https://bootcamp.rhinops.io/images/week-4-project-env.png)
 
Github link for the application https://github.com/TamirAtia/bootcamp-app

## Configuration:
* clone this reposetory
* Use `azurerm` as a [provider](https://www.terraform.io/docs/language/providers/configuration.html).
* Create `.tfvars` file for your variables in the root
* run in the cli "terraform init"
* run in the cli "terraform apply"

in `.tfvars` you will need to create this variable
```
resource_group_name             
location                        
address_space                   
subnet_public_prefix            
subnet_private_prefix           
virtual_network_name            
num_of_instances                
admin_username                  
admin_password                  
postgres_administrator_login    
postgres_administrator_password 
myIP_Address
```


# Project Description

In this week’s project we are going to recreate the infrastructure of the WeightTracker application but this time instead of doing it manually we are going to use Terraform to automate this process. The infrastructure that you have to deploy is the same as last week’s project with the first bonus (High Availability).



## Goals
1. Use Terraform to define all the infrastructure

2. Use Terraform variables to configure at least 5 parameters for your template

3. Configure a Terraform output to retrieve the VM password (Linux servers must be configured with password authentication instead of SSH keys)

4. Create a terraform module to reuse the code that creates the virtual machines

5. Install the WeightTracker application and the Database into the VMs created by terraform (the installation can be done manually)

6. Ensure the application is up and running (and work automatically after reboot)



## Terraform Installing

We have to use a terraform platform and let's get practice first with a simple hands on manual

https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/azure-get-started

https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure

then we will build our app environment using infrastructure as a code (IaaC) in Azure cloud

https://azure.microsoft.com/en-us/account/





