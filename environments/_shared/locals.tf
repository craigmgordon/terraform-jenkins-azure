locals {
  # Core identifiers
  project     = "jenkins"
  cost_centre = "platform"        # adjust if client has one
  owner       = "gsi"             # or your team name
  managed_by  = "terraform"

  # Normalised environment name helper (optional)
  env = lower(var.environment)

  # Common tags applied to all resources
  common_tags = merge(
    {
      project     = local.project
      environment = local.env
      owner       = local.owner
      costcentre  = local.cost_centre
      managed_by  = local.managed_by
    },
    var.tags
  )

  # Standard naming (keeps names consistent across stacks)
  name_prefix = "${var.name}-${local.env}"

  # Default locations / settings (only if you truly want them shared)
  location = var.location

  # Convention: resource name helpers (useful if you want consistent names)
  rg_name           = "rg-${local.name_prefix}"
  vnet_name         = "vnet-${local.name_prefix}"
  controller_vm_name = "vm-${local.name_prefix}-jenkins-ctrl"
  controller_disk_name = "disk-${local.name_prefix}-jenkins-home"

  # Network conventions (optional; if you want envs to override, keep in variables instead)
  # Example placeholders - only use if you're standardising CIDRs in one place:
  # vnet_cidr              = "10.50.0.0/16"
  # controller_subnet_cidr = "10.50.1.0/24"

  # Jenkins defaults (can be overridden in env tfvars if you expose variables)
  jenkins = {
    image            = "jenkins/jenkins:lts-jdk17"
    http_port        = 8080
    agent_port       = 50000
    home_mount_point = "/var/jenkins_home"
    data_disk_lun    = 0
  }
}