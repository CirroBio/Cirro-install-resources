variable "data_portal_account_id" {
  type = string
  description = "Account ID of Cirro Tenant"
}
variable "deploy_ous" {
  type = string
  description = "This role deploys to the accounts located in these organizational units"
}
variable "deploy_account_ids" {
  type = string
  description = "This role deploys to these account IDs"
}
variable "stack_set_name" {
  type = string
  default = "Cirro-ProjectDeploymentRoleStackSet"
  description = "Override stack set name"
}
variable "max_concurrent_operations" {
  type = number
  default = 50
  description = "Maximum number of accounts to concurrently deploy this role to"
}
