variable "environment" { type = string }
variable "name"        { type = string }
variable "location"    { type = string }

variable "resource_group_name" { type = string }
variable "tags"                { type = map(string) }

variable "vnet_cidr"              { type = string }
variable "controller_subnet_cidr" { type = string }

variable "controller_vm_size" { type = string }
variable "admin_username"     { type = string }
variable "ssh_public_key"     { type = string }

variable "data_disk_size_gb" { type = number }
variable "data_disk_sku"     { type = string } # Premium_LRS / StandardSSD_LRS

variable "jenkins_image" { type = string }
