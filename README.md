# Cirro-install-resources

Repository for CloudFormation templates used to install Cirro.

This repository updates periodically, so make sure to keep your role up-to-date.

## Deployment

You can get the account ID parameter from the pre-filled CloudFormation deployment wizard when creating a Cirro project, or by contacting Cirro support.

### Terraform (Organization)

If your organization already has Terraform set up to manage your AWS infrastructure, using our module is the easiest way to get started.
You can also copy/paste the contents of [`cirro_project_deploy_role.tf`](modules/cirro_deploy_role/role.tf) into your existing setup.

The module will use CloudFormation StackSets to deploy the template automatically to specified target accounts and/or organizational units (OUs).

It is recommended to keep all Cirro-related accounts in an OU to make deployment easy.

```terraform
module "cirro_deploy_role" {
  source = "./modules/cirro_deploy_role"
  # or direct from GitHub, if you'd prefer
  # source = "git::https://github.com/CirroBio/Cirro-install-resources.git//modules/cirro_deploy_role"
  
  data_portal_account_id = "1234567890"
  
  # Organization units to deploy this role to
  deploy_ous = []
  # Account IDs to deploy this role to
  deploy_account_ids = []
}
```

### CloudFormation

#### Stack Sets (Organization)

1. Go to CloudFormation → StackSets → Create StackSet.
2. Use **Service-managed permissions**.
3. Use **Template is ready**
4. Upload the template in the wizard or use our [S3 mirror](#s3-mirror).
5. Enter a name for the StackSet (e.g. **CirroProjectDeploymentRoleStackSet**).
6. Enter the parameters:
   - `pDataPortalAccountId`
   - `pAccountOwner`, this can be left blank in a typical organization setup.
7. Select **Active** under Execution configuration
8. Select **Deploy to organizational units (OUs)**. Enter the OU ID where your Cirro project accounts are located.
9. Select a number for **Maximum concurrent accounts** and **Failure tolerance**. 50+ is a good number in order to concurrently deploy the role. This is fine for simple stacks.

#### Stack (Individual Account)

In the Create Project interface, select **I want to use my own AWS account** and click the **CloudFormation Wizard** to bring up the wizard with all the details filled in.

You can also manually launch the CloudFormation Create stack wizard through the AWS Console. Use the S3 mirror when providing the template source.

#### Support access role (Optional)

[`cirro_support_access_role.yml`](cirro_support_access_role.yml) deploys a role that Cirro support can assume to help debug or set up the account.
Deploy it as a stack in the account, entering your Cirro tenant account ID for `pDataPortalAccountId`, and share the `SupportAccessRoleArn` output with Cirro support.
Only Cirro support staff signed in through the tenant account's support single sign-on role can assume it.
To limit access to specific people, enter their user names in `pSupportUsers` (e.g. `su-jdoe@cirro.bio`).
Set `pAccessExpiry` to make the access expire automatically, or delete the stack to revoke it.

The role has administrative access to the services Cirro uses, with guardrails:

- No access to other services, billing, organization or account settings.
- No launching compute: instances, fleets, Auto Scaling groups, Batch jobs, ECS tasks and services, HealthOmics runs. SageMaker is view, stop and delete only.
- No purchases or commitments (reservations, capacity, hosts) and no service quota increases.
- No deleting S3 objects, table buckets, file systems or KMS keys, and no deleting shared networking.
- No public ACLs, snapshot/image sharing, or reading secrets and parameters that do not belong to Cirro.
- IAM changes are limited to Cirro roles and policies, which stay capped by the Cirro permissions boundary. It cannot create users or access keys, assume other roles, or change itself.
- By default it cannot edit the Cirro permissions boundary, so it cannot deploy or update the project deployment role stack.
  Set `pAllowDeploymentRoleChanges` to `true` to let support deploy and update that stack. This lets support change what the boundary allows, so Cirro roles are no longer capped by it.

#### S3 Mirror

- Project deployment role: https://cirro-marketplace-assets.s3.us-west-2.amazonaws.com/cirro_project_deployment_role.yml
- Support access role: https://cirro-marketplace-assets.s3.us-west-2.amazonaws.com/cirro_support_access_role.yml

#### Updating the role

You can update the stack by:

1. Go to CloudFormation → Stacks → Select the deployment role
2. Click **Update Stack** -> **Make a direct update**
3. **Replace existing template**
4. Enter the S3 mirror URL as the template source (or upload the `.yml` manually)
5. No other changes are necessary, click Next and Submit to deploy the new template

The process for updating the stack set is similar:

1. Go to CloudFormation → StackSets → Select the deployment role stack set
2. Click **Actions** → **Edit stack set details**
3. Under **Prepare template**, select **Replace current template**
4. Enter the S3 mirror URL as the template source (or upload the `.yml` manually)
5. Continue until Submit.
