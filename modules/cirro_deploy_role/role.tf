resource "aws_cloudformation_stack_set" "project_deploy_role" {
  name             = var.stack_set_name
  capabilities     = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM"]
  permission_model = "SERVICE_MANAGED"

  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }

  operation_preferences {
    max_concurrent_count    = var.max_concurrent_operations
    failure_tolerance_count = var.max_concurrent_operations
  }

  parameters = {
    pRoleName                = "Cirro-ProjectDeploymentBaseRole"
    pPermissionsBoundaryName = "CirroPermissionsBoundary",
    pDataPortalAccountId     = var.data_portal_account_id
    pEnvironmentPrefix       = "Cirro"
    pAccountOwner            = ""  // This is not used in org-wide deployments
  }

  template_body = file("${path.module}/../cirro_project_deployment_role.yml")

  lifecycle {
    ignore_changes = [administration_role_arn]
  }
}

resource "aws_cloudformation_stack_set_instance" "project_deploy_role_ou" {
  stack_set_name = aws_cloudformation_stack_set.project_deploy_role.name

  region = local.region

  deployment_targets {
    organizational_unit_ids = var.deploy_ous
    account_filter_type = "UNION"
    accounts = var.deploy_account_ids
  }
}
