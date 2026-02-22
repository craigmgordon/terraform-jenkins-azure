resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source              = "../../modules/network"
  name                = local.name_prefix
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  vnet_cidr   = var.vnet_cidr
  subnet_cidr = var.controller_subnet_cidr

  tags = local.common_tags
}

module "controller" {
  source              = "../../modules/jenkins_controller_vm"
  name                = "${local.name_prefix}-jenkins-ctrl"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = module.network.subnet_id

  vm_size        = var.controller_vm_size
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key

  data_disk_size_gb = var.data_disk_size_gb
  data_disk_sku     = var.data_disk_sku

  jenkins_image = var.jenkins_image

  tags = local.common_tags
}
