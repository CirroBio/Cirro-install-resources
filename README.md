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

The easiest 
In the Create Project interface, select **I want to use my own AWS account** and click the **CloudFormation Wizard** to bring up the wizard with all the details filled in.

You can also manually launch the CloudFormation Create stack wizard through the AWS Console. Use the S3 mirror when providing the template source.

#### S3 Mirror

https://cirro-marketplace-assets.s3.us-west-2.amazonaws.com/cirro_project_deployment_role.yml

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
