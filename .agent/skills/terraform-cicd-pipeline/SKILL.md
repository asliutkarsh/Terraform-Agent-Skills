---
name: terraform-cicd-pipeline
description: Generate GitHub Actions workflows for Terraform plan/apply with OIDC authentication following Hub-Spoke architecture patterns. Use when creating CI/CD pipelines, setting up deployment workflows, configuring GitHub Actions for Terraform, or automating infrastructure deployments. Triggers include "create pipeline", "setup CI/CD", "GitHub Actions", "workflow", or "automate deployment".
---

# Terraform CI/CD Pipeline Generator

Generate compliant GitHub Actions workflows for Terraform deployments with plan-apply pattern and OIDC authentication.

## Overview

The CI/CD system uses:
- **Reusable workflows**: Centralized plan and apply logic
- **Caller workflows**: Project-specific orchestration
- **Plan-Apply pattern**: Manual approval between plan and apply
- **OIDC authentication**: No long-lived secrets
- **Artifact storage**: Plan files passed between jobs

## Pipeline Architecture

```
Caller Workflow (e.g., abc-project-plan-apply.yml)
    │
    ├──> Plan Job (terraform-plan.yml)
    │    ├── Terraform Init
    │    ├── Terraform Validate
    │    ├── Security Scan
    │    ├── Terraform Plan
    │    └── Upload Artifact (tfplan)
    │
    └──> Apply Job (terraform-apply.yml)
         ├── Download Artifact (tfplan)
         ├── Manual Approval (GitHub Environment)
         └── Terraform Apply
```

## Required Secrets

Ensure these secrets exist in GitHub repository settings:

| Secret Name | Description | Example Value |
|------------|-------------|---------------|
| `AZURE_CLIENT_ID` | OIDC Client ID | `12345678-1234-1234-1234-123456789abc` |
| `AZURE_TENANT_ID` | Azure Tenant ID | `87654321-4321-4321-4321-cba987654321` |
| `AZURE_SUBSCRIPTION_ID` | Target Subscription | `abcdef12-3456-7890-abcd-ef1234567890` |
| `TF_STATE_SA_NAME` | State Storage Account | `stajfchubcindata01` |
| `TF_STATE_CONTAINER` | State Container | `tfstate` |
| `TF_STATE_RG` | State Resource Group | `rg-ajfc-hub-cin-data-01` |

## Workflow Generation

### For Hub/Core Components

Generate caller workflow for Hub components:

```yaml
name: Core-<Component>-Deploy

on:
  workflow_dispatch:
  push:
    branches:
      - main
    paths:
      - 'Workload/Core/<component>/**'
      - 'Deployment/Core/<component>/**'

permissions:
  id-token: write
  contents: read

jobs:
  plan:
    uses: ./.github/workflows/terraform-plan.yml
    with:
      working_directory: Workload/Core/<component>
      state_key: core/<component>.tfstate
      component_name: core-<component>
      tfvars_file: Deployment/Core/<component>/<component>.tfvars
    secrets: inherit

  apply:
    needs: plan
    uses: ./.github/workflows/terraform-apply.yml
    with:
      working_directory: Workload/Core/<component>
      state_key: core/<component>.tfstate
      component_name: core-<component>
      environment: production
    secrets: inherit
```

**Replace `<component>` with:** `network`, `data`, `compute`, `ai`, `identity`, or `governance`

### For Spoke Projects

Generate caller workflow for Spoke projects:

```yaml
name: <Project>-Deploy

on:
  workflow_dispatch:
    inputs:
      component:
        description: "Component to deploy"
        required: true
        type: choice
        options:
          - network
          - data
          - compute
          - ai

permissions:
  id-token: write
  contents: read

jobs:
  plan:
    uses: ./.github/workflows/terraform-plan.yml
    with:
      working_directory: Workload/Spokes/<project>/${{ inputs.component }}
      state_key: spokes/<project>/${{ inputs.component }}.tfstate
      component_name: <project>-${{ inputs.component }}
      tfvars_file: Deployment/Spokes/<project>/${{ inputs.component }}/${{ inputs.component }}.tfvars
    secrets: inherit

  apply:
    needs: plan
    uses: ./.github/workflows/terraform-apply.yml
    with:
      working_directory: Workload/Spokes/<project>/${{ inputs.component }}
      state_key: spokes/<project>/${{ inputs.component }}.tfstate
      component_name: <project>-${{ inputs.component }}
      environment: production
    secrets: inherit
```

**Replace `<project>` with:** Your project code (e.g., `ragbot`, `custbot`)

## Reusable Workflow: terraform-plan.yml

This is the centralized plan workflow (already exists in `.github/workflows/`):

```yaml
name: Terraform Plan (Reusable)

on:
  workflow_call:
    inputs:
      working_directory:
        description: 'Path to Terraform code'
        required: true
        type: string
      tfvars_file:
        description: 'Path to .tfvars file'
        required: true
        type: string
      state_key:
        description: 'State file key'
        required: true
        type: string
      component_name:
        description: 'Component identifier for artifact'
        required: true
        type: string

jobs:
  plan:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.0

      - name: Azure Login (OIDC)
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Terraform Init
        working-directory: ${{ inputs.working_directory }}
        run: |
          terraform init \
            -backend-config="storage_account_name=${{ secrets.TF_STATE_SA_NAME }}" \
            -backend-config="container_name=${{ secrets.TF_STATE_CONTAINER }}" \
            -backend-config="key=${{ inputs.state_key }}" \
            -backend-config="resource_group_name=${{ secrets.TF_STATE_RG }}"

      - name: Terraform Validate
        working-directory: ${{ inputs.working_directory }}
        run: terraform validate

      - name: Terraform Format Check
        working-directory: ${{ inputs.working_directory }}
        run: terraform fmt -check -recursive

      - name: Terraform Plan
        working-directory: ${{ inputs.working_directory }}
        run: |
          terraform plan \
            -var-file="../../../${{ inputs.tfvars_file }}" \
            -out=tfplan

      - name: Upload Plan Artifact
        uses: actions/upload-artifact@v4
        with:
          name: ${{ inputs.component_name }}-tfplan
          path: ${{ inputs.working_directory }}/tfplan
          retention-days: 5
```

## Reusable Workflow: terraform-apply.yml

This is the centralized apply workflow:

```yaml
name: Terraform Apply (Reusable)

on:
  workflow_call:
    inputs:
      working_directory:
        description: 'Path to Terraform code'
        required: true
        type: string
      state_key:
        description: 'State file key'
        required: true
        type: string
      component_name:
        description: 'Component identifier for artifact'
        required: true
        type: string
      environment:
        description: 'GitHub Environment for approvals'
        required: true
        type: string

jobs:
  apply:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.0

      - name: Download Plan Artifact
        uses: actions/download-artifact@v4
        with:
          name: ${{ inputs.component_name }}-tfplan
          path: ${{ inputs.working_directory }}

      - name: Azure Login (OIDC)
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Terraform Init
        working-directory: ${{ inputs.working_directory }}
        run: |
          terraform init \
            -backend-config="storage_account_name=${{ secrets.TF_STATE_SA_NAME }}" \
            -backend-config="container_name=${{ secrets.TF_STATE_CONTAINER }}" \
            -backend-config="key=${{ inputs.state_key }}" \
            -backend-config="resource_group_name=${{ secrets.TF_STATE_RG }}"

      - name: Terraform Apply
        working-directory: ${{ inputs.working_directory }}
        run: terraform apply -auto-approve tfplan
```

## Path Alignment Rules

Critical: Paths must align correctly between directories:

| Layer | Hub/Core | Spoke |
|-------|---------|-------|
| **Code** | `Workload/Core/<component>` | `Workload/Spokes/<project>/<component>` |
| **Config** | `Deployment/Core/<component>` | `Deployment/Spokes/<project>/<component>` |
| **State Key** | `core/<component>.tfstate` | `spokes/<project>/<component>.tfstate` |

### Example: Hub Network

```yaml
working_directory: Workload/Core/network
tfvars_file: Deployment/Core/network/network.tfvars
state_key: core/network.tfstate
component_name: core-network
```

### Example: Spoke RagBot Data

```yaml
working_directory: Workload/Spokes/ragbot/data
tfvars_file: Deployment/Spokes/ragbot/data/data.tfvars
state_key: spokes/ragbot/data.tfstate
component_name: ragbot-data
```

## GitHub Environment Setup

Configure manual approvals in GitHub:

1. Go to **Settings** → **Environments**
2. Create environment named `production`
3. Add **Required reviewers** (select team members)
4. Optional: Add **Wait timer** (e.g., 5 minutes)

## Workflow Triggers

### Manual Trigger (workflow_dispatch)

Run on-demand from GitHub Actions UI:
- Select workflow
- Choose component (for Spokes)
- Click "Run workflow"

### Automatic Trigger (push)

Run automatically on code changes:

```yaml
on:
  push:
    branches:
      - main
    paths:
      - 'Workload/Core/network/**'
      - 'Deployment/Core/network/**'
```

### Pull Request Trigger (plan-only)

For PR validation:

```yaml
on:
  pull_request:
    paths:
      - 'Workload/**'
      - 'Deployment/**'

jobs:
  plan:
    # Only run plan job, skip apply
```

## Common Patterns

### Multi-Environment Spoke

Deploy same project to dev/uat/prod:

```yaml
name: RagBot-MultiEnv-Deploy

on:
  workflow_dispatch:
    inputs:
      environment:
        description: "Environment"
        required: true
        type: choice
        options:
          - dev
          - uat
          - prod
      component:
        description: "Component"
        required: true
        type: choice
        options:
          - network
          - data
          - compute
          - ai

jobs:
  plan:
    uses: ./.github/workflows/terraform-plan.yml
    with:
      working_directory: Workload/Spokes/ragbot/${{ inputs.component }}
      state_key: spokes/ragbot/${{ inputs.environment }}/${{ inputs.component }}.tfstate
      component_name: ragbot-${{ inputs.environment }}-${{ inputs.component }}
      tfvars_file: Deployment/Spokes/ragbot/${{ inputs.environment }}/${{ inputs.component }}.tfvars
    secrets: inherit

  apply:
    needs: plan
    uses: ./.github/workflows/terraform-apply.yml
    with:
      working_directory: Workload/Spokes/ragbot/${{ inputs.component }}
      state_key: spokes/ragbot/${{ inputs.environment }}/${{ inputs.component }}.tfstate
      component_name: ragbot-${{ inputs.environment }}-${{ inputs.component }}
      environment: ${{ inputs.environment }}
    secrets: inherit
```

### Dependent Component Deployment

Deploy components in sequence:

```yaml
jobs:
  plan-network:
    uses: ./.github/workflows/terraform-plan.yml
    with:
      working_directory: Workload/Spokes/ragbot/network
      state_key: spokes/ragbot/network.tfstate
      component_name: ragbot-network
      tfvars_file: Deployment/Spokes/ragbot/network/network.tfvars
    secrets: inherit

  apply-network:
    needs: plan-network
    uses: ./.github/workflows/terraform-apply.yml
    with:
      working_directory: Workload/Spokes/ragbot/network
      state_key: spokes/ragbot/network.tfstate
      component_name: ragbot-network
      environment: production
    secrets: inherit

  plan-data:
    needs: apply-network
    uses: ./.github/workflows/terraform-plan.yml
    with:
      working_directory: Workload/Spokes/ragbot/data
      state_key: spokes/ragbot/data.tfstate
      component_name: ragbot-data
      tfvars_file: Deployment/Spokes/ragbot/data/data.tfvars
    secrets: inherit

  apply-data:
    needs: plan-data
    uses: ./.github/workflows/terraform-apply.yml
    with:
      working_directory: Workload/Spokes/ragbot/data
      state_key: spokes/ragbot/data.tfstate
      component_name: ragbot-data
      environment: production
    secrets: inherit
```

## Troubleshooting

For detailed troubleshooting steps and common issues, see [references/troubleshooting.md](references/troubleshooting.md).

### Quick Fixes

**Path not found:**
```yaml
# Ensure tfvars_file path is relative from repo root
tfvars_file: Deployment/Spokes/ragbot/data/data.tfvars
# NOT: ../../../Deployment/...
```

**State lock errors:**
```bash
# Manually unlock state if workflow cancelled
az storage blob lease break \
  --account-name stajfchubcindata01 \
  --container-name tfstate \
  --blob-name spokes/ragbot/data.tfstate
```

**OIDC authentication failed:**
- Verify `AZURE_CLIENT_ID` secret exists
- Check federated credential subject matches repository
- Ensure managed identity has proper RBAC

## Validation Checklist

Before deploying workflow:

- [ ] Reusable workflows exist in `.github/workflows/`
- [ ] All required secrets configured
- [ ] GitHub Environment created with reviewers
- [ ] Path alignment matches directory structure
- [ ] State key follows naming pattern
- [ ] Component name is unique
- [ ] OIDC federated credential configured

## Next Steps

After creating workflow:
1. Commit workflow file to repository
2. Test with manual trigger
3. Review plan output in Actions logs
4. Approve apply step
5. Verify resources created in Azure
6. Add automatic triggers if needed

For complete workflow examples and advanced patterns, see [references/workflow-examples.md](references/workflow-examples.md).