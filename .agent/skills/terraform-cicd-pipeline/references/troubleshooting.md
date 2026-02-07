# CI/CD Pipeline Troubleshooting

Common issues and solutions for Terraform CI/CD pipelines.

## Authentication Issues

### OIDC Authentication Failed

**Error:**
```
Error: Unable to authenticate to Azure
AADSTS70021: No matching federated identity record found
```

**Causes:**
1. Federated credential subject doesn't match repository
2. Client ID secret incorrect
3. Managed identity doesn't exist

**Solutions:**

1. Verify federated credential subject:
```bash
# Check federated credential
az identity federated-credential show \
  --name github-main \
  --identity-name id-ajfc-hub-cin-github-terraform-01 \
  --resource-group rg-ajfc-hub-cin-identity-01
```

Expected subject format:
```
repo:organization/repository:ref:refs/heads/main
```

2. Verify GitHub secret:
- Go to Settings → Secrets → Actions
- Check `AZURE_CLIENT_ID` matches identity's client ID

3. Get correct client ID:
```bash
az identity show \
  --name id-ajfc-hub-cin-github-terraform-01 \
  --resource-group rg-ajfc-hub-cin-identity-01 \
  --query clientId -o tsv
```

### Missing Permissions

**Error:**
```
Error: authorization failed
The client does not have authorization to perform action
```

**Cause:** Managed identity lacks RBAC permissions

**Solution:**

1. Check current role assignments:
```bash
az role assignment list \
  --assignee $(az identity show \
    --name id-ajfc-hub-cin-github-terraform-01 \
    --resource-group rg-ajfc-hub-cin-identity-01 \
    --query principalId -o tsv)
```

2. Assign required role:
```bash
# For subscription-level access
az role assignment create \
  --assignee <identity-principal-id> \
  --role "Owner" \
  --scope "/subscriptions/<subscription-id>"
```

## State Management Issues

### State File Not Found

**Error:**
```
Error: Failed to get existing workspaces
Error reading state: blob not found
```

**Cause:** Incorrect state key or container

**Solution:**

1. Verify state key format:
```yaml
# Hub
state_key: core/network.tfstate

# Spoke
state_key: spokes/ragbot/data.tfstate
```

2. Check state container exists:
```bash
az storage container show \
  --name tfstate \
  --account-name stajfchubcindata01
```

3. List existing state files:
```bash
az storage blob list \
  --container-name tfstate \
  --account-name stajfchubcindata01 \
  --query "[].name" -o tsv
```

### State Lock Timeout

**Error:**
```
Error: Error acquiring the state lock
Lock Info:
  ID: 12345678-1234-1234-1234-123456789abc
```

**Cause:** Previous workflow cancelled or failed mid-run

**Solution:**

1. Check if workflow is still running
2. If not, force unlock:

```bash
# Using Terraform CLI
cd Workload/Spokes/ragbot/data
terraform force-unlock 12345678-1234-1234-1234-123456789abc

# OR using Azure CLI
az storage blob lease break \
  --account-name stajfchubcindata01 \
  --container-name tfstate \
  --blob-name spokes/ragbot/data.tfstate
```

### State Corruption

**Error:**
```
Error: state snapshot was created by Terraform v1.6.0
This is newer than current v1.5.0
```

**Cause:** State modified by newer Terraform version

**Solution:**

1. Update Terraform version in workflow:
```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: 1.6.0  # Match state version
```

2. Or restore from backup:
```bash
# List backup versions
az storage blob list \
  --container-name tfstate \
  --account-name stajfchubcindata01 \
  --prefix spokes/ragbot/data.tfstate

# Restore from backup
az storage blob copy start \
  --destination-blob spokes/ragbot/data.tfstate \
  --destination-container tfstate \
  --account-name stajfchubcindata01 \
  --source-uri "<backup-blob-url>"
```

## Path and File Issues

### Tfvars File Not Found

**Error:**
```
Error: Failed to read variables file
No such file or directory
```

**Cause:** Incorrect tfvars_file path

**Solution:**

Path must be relative from repository root:

```yaml
# ✅ Correct
tfvars_file: Deployment/Spokes/ragbot/data/data.tfvars

# ❌ Wrong
tfvars_file: ../../../Deployment/Spokes/ragbot/data/data.tfvars
```

Verify file exists:
```bash
ls -la Deployment/Spokes/ragbot/data/data.tfvars
```

### Working Directory Not Found

**Error:**
```
Error: chdir: no such file or directory
```

**Cause:** Incorrect working_directory path

**Solution:**

Verify directory structure:
```bash
ls -la Workload/Spokes/ragbot/data/
# Should show: main.tf, variables.tf, outputs.tf, providers.tf
```

Ensure path is correct in workflow:
```yaml
working_directory: Workload/Spokes/ragbot/data
```

### Module Not Found

**Error:**
```
Error: Module not found
Could not load module "../../../Modules/resource_group"
```

**Cause:** Incorrect module source path

**Solution:**

Module paths are relative to the component directory:

```hcl
# From: Workload/Spokes/ragbot/data/main.tf
# To:   Modules/resource_group/

# ✅ Correct (4 levels up)
module "resource_group" {
  source = "../../../../Modules/resource_group"
}

# Count levels: data -> ragbot -> Spokes -> Workload -> (root)
```

## Artifact Issues

### Artifact Not Found

**Error:**
```
Error: Unable to find artifact
Artifact 'ragbot-data-tfplan' not found
```

**Cause:** Plan job failed or artifact expired

**Solution:**

1. Check plan job succeeded:
- View workflow run
- Ensure plan job completed successfully

2. Check artifact name matches:
```yaml
# In plan job
component_name: ragbot-data

# In apply job (must match)
component_name: ragbot-data
```

3. Artifact retention (default 5 days):
```yaml
- name: Upload Plan Artifact
  uses: actions/upload-artifact@v4
  with:
    name: ${{ inputs.component_name }}-tfplan
    path: ${{ inputs.working_directory }}/tfplan
    retention-days: 5  # Increase if needed
```

### Artifact Corrupted

**Error:**
```
Error: Failed to read plan
Invalid plan file format
```

**Cause:** Terraform version mismatch between plan and apply

**Solution:**

Ensure same Terraform version in both jobs:
```yaml
# Both plan and apply workflows
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    terraform_version: 1.5.0  # Must match exactly
```

## Validation and Format Issues

### Format Check Failed

**Error:**
```
Error: terraform fmt -check failed
Files not formatted correctly
```

**Cause:** Code not formatted per Terraform standards

**Solution:**

Format code locally:
```bash
cd Workload/Spokes/ragbot/data
terraform fmt -recursive
git add .
git commit -m "Format Terraform code"
```

### Validation Failed

**Error:**
```
Error: Invalid reference
A managed resource "azurerm_resource_group" has not been declared
```

**Cause:** Missing resource or incorrect reference

**Solution:**

1. Check resource exists:
```bash
grep -r "azurerm_resource_group" Workload/Spokes/ragbot/data/
```

2. Verify module dependencies:
```hcl
module "storage" {
  source = "../../../../Modules/storage"
  
  resource_group_name = module.resource_group.resource_group_name
  
  depends_on = [module.resource_group]  # Ensure this exists
}
```

## Environment and Approval Issues

### Environment Not Found

**Error:**
```
Error: Environment 'production' not found
```

**Cause:** GitHub Environment not configured

**Solution:**

1. Create environment:
- Go to Settings → Environments
- Click "New environment"
- Name: `production`

2. Add reviewers:
- Select environment
- Add required reviewers
- Save protection rules

### Approval Timeout

**Error:**
```
Error: Workflow run timed out
Waiting for approvals exceeded timeout
```

**Cause:** No one approved within timeout period

**Solution:**

1. Increase timeout in environment settings:
- Settings → Environments → production
- Wait timer: adjust value

2. Notify reviewers:
- GitHub sends email notifications
- Check spam folders
- Add more reviewers as backup

## Secret Management Issues

### Missing Secret

**Error:**
```
Error: Required secret 'AZURE_CLIENT_ID' not found
```

**Cause:** Secret not configured in GitHub

**Solution:**

1. Add secret:
- Go to Settings → Secrets → Actions
- Click "New repository secret"
- Name: `AZURE_CLIENT_ID`
- Value: Your client ID
- Click "Add secret"

2. Verify all required secrets exist:
```yaml
Required secrets:
- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- AZURE_SUBSCRIPTION_ID
- TF_STATE_SA_NAME
- TF_STATE_CONTAINER
- TF_STATE_RG
```

### Secret Value Incorrect

**Cause:** Typo or wrong value in secret

**Solution:**

1. Get correct values from Azure:
```bash
# Client ID
az identity show \
  --name id-ajfc-hub-cin-github-terraform-01 \
  --resource-group rg-ajfc-hub-cin-identity-01 \
  --query clientId -o tsv

# Tenant ID
az account show --query tenantId -o tsv

# Subscription ID
az account show --query id -o tsv
```

2. Update secret:
- Settings → Secrets → Actions
- Click secret name
- Update value
- Save changes

## Performance Issues

### Slow Plan/Apply

**Symptom:** Jobs take >30 minutes

**Causes:**
1. Large state file
2. Too many resources
3. Network latency

**Solutions:**

1. Split into smaller components:
```
# Instead of one large "data" component
Workload/Spokes/ragbot/data-storage/
Workload/Spokes/ragbot/data-databases/
Workload/Spokes/ragbot/data-messaging/
```

2. Use target for specific resources:
```yaml
- name: Terraform Plan
  run: |
    terraform plan \
      -target=module.storage_account \
      -var-file="../../../${{ inputs.tfvars_file }}" \
      -out=tfplan
```

3. Enable parallelism:
```yaml
- name: Terraform Apply
  run: terraform apply -auto-approve -parallelism=20 tfplan
```

## Debugging Tips

### Enable Detailed Logging

Add to workflow:
```yaml
- name: Terraform Plan
  env:
    TF_LOG: DEBUG
  run: terraform plan ...
```

### View State

```bash
# Show current state
terraform show

# List resources
terraform state list

# Show specific resource
terraform state show azurerm_resource_group.example
```

### Manual Workflow Run

Test locally before CI/CD:
```bash
# Set environment variables
export AZURE_CLIENT_ID="..."
export AZURE_TENANT_ID="..."
export AZURE_SUBSCRIPTION_ID="..."

# Login
az login --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID --federated-token $(curl -H "Authorization: bearer $ACTIONS_ID_TOKEN_REQUEST_TOKEN" "$ACTIONS_ID_TOKEN_REQUEST_URL" | jq -r .value)

# Run Terraform
terraform init ...
terraform plan ...
```

## Getting Help

If issues persist:

1. Check workflow logs in GitHub Actions
2. Review Azure Activity Log for RBAC issues
3. Verify all paths match directory structure
4. Test Terraform commands locally
5. Contact platform team for state/RBAC issues