environment         = "dev"
name                = "gsi"
location            = "uksouth"
resource_group_name = "rg-gsi-jenkins-dev"

tags = {
  owner = "craig"
  team  = "platform"
}

vnet_cidr              = "10.50.0.0/16"
controller_subnet_cidr = "10.50.1.0/24"

controller_vm_size = "Standard_D4s_v5"
admin_username     = "azureuser"
ssh_public_key     = "ssh-rsa AAAA...REPLACE..."

data_disk_size_gb = 128
data_disk_sku     = "Premium_LRS"

jenkins_image = "jenkins/jenkins:lts-jdk17"
