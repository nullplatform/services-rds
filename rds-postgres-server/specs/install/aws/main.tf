################################################################################
# Install — registers the rds-postgres-server service definition and its
# agent association (notification channel) on a nullplatform account.
#
# This is the platform-registration half of adopting the service; the
# AWS AssumeRole IAM role/policies live in ../../requirements/aws and are
# applied separately (see that module's README and the top-level
# "AssumeRole Setup Guide" in ../../../README.md).
#
# The agent association takes no API key: nullplatform creates and manages the
# notification channel's credential, scoped to dispatching commands to agents.
# The identity running the apply must be able to assign the
# controlplane:agent-dispatcher role (admin, ops or secops).
################################################################################

locals {
  service_path      = "databases/rds-postgres-server"
  available_links   = ["connect"]
  available_actions = []
}

module "service_definition" {
  source = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/service_definition?ref=v4.5.1"

  nrn               = var.nrn
  repository_org    = var.repository_org
  repository_name   = var.repository_name
  repository_branch = var.repository_branch
  repository_token  = var.repository_token
  service_path      = local.service_path
  service_name      = var.service_name
  available_links   = local.available_links
  available_actions = local.available_actions
}

module "service_definition_agent_association" {
  source = "git::https://github.com/nullplatform/tofu-modules.git//nullplatform/service_definition_agent_association?ref=v8.7.0"

  nrn                          = var.nrn
  repository_service_spec_repo = "${var.repository_org}/${var.repository_name}"
  service_path                 = local.service_path
  service_specification_slug   = module.service_definition.service_specification_slug
  tags_selectors               = var.tags_selectors
}
