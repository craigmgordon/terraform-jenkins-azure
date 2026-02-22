# Dev Apply Pipeline (`.azure-pipelines/apply-dev.yml`)

This file defines an Azure Pipelines workflow that creates a Terraform plan for the `dev` environment using Azure service-connection authentication, then publishes the plan artifacts.

Despite the file name (`apply-dev.yml`), this pipeline currently performs **init + plan + publish** only. It does **not** run `terraform apply`.

## What It Does

The pipeline executes these high-level actions:

- Runs on pushes to `main`.
- Installs a pinned Terraform version (`1.6.6`) on the build agent.
- Authenticates to Azure through an Azure DevOps service connection.
- Exports `ARM_*` environment variables expected by the `azurerm` Terraform provider.
- Runs `terraform init` and `terraform plan` in `environments/dev` using `dev.tfvars`.
- Produces both a binary plan file and a text rendering of the plan.
- Publishes both files as pipeline artifacts for downstream usage or manual review.

## Why Each Section Exists

### Triggering

- `trigger.branches.include: main`
  - Runs this pipeline when code is merged/pushed to `main`.
- `pr: none`
  - Prevents this pipeline from running on pull requests.
  - Keeps PR checks separate from post-merge deployment planning workflows.

### Agent

- `pool.vmImage: ubuntu-latest`
  - Uses a Microsoft-hosted Linux agent.
  - Ensures consistent runtime behavior without relying on self-hosted agent configuration.

### Variables

- `TF_VERSION`
  - Pins Terraform to a predictable version to avoid drift across agents.
- `TF_ENV_DIR`
  - Centralizes the dev Terraform directory path (`environments/dev`).
- `TF_VARS_FILE`
  - Explicitly points to the dev variable file (`dev.tfvars`).
- `PLAN_FILE`
  - Standardizes plan output naming (`tfplan`).

These variables reduce duplication and make future edits safer.

### Checkout Step

- `checkout: self`
  - Fetches repository contents so Terraform can run against local code.
- `fetchDepth: 0`
  - Uses full history (useful if later steps depend on git metadata).

### Install Terraform Step

- Downloads the exact Terraform zip for Linux AMD64.
- Unzips to `/usr/local/bin`.
- Prints `terraform version` to confirm successful install.

This avoids relying on whatever Terraform version might already be on the hosted image.

### AzureCLI Terraform Plan Step

This is the critical infrastructure validation step.

- Uses `AzureCLI@2` with `addSpnToEnvironment: true`.
- Reads service principal credentials injected by Azure DevOps.
- Exports:
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`
  - `ARM_TENANT_ID`
  - `ARM_SUBSCRIPTION_ID`
- Sets `TF_IN_AUTOMATION=true` for non-interactive CI behavior.
- Changes directory to `environments/dev`.
- Runs:
  - `terraform init -input=false`
  - `terraform plan -input=false -var-file=dev.tfvars -out=tfplan`
- Renders human-readable output:
  - `terraform show -no-color tfplan > tfplan.txt`

Why this matters:
- The binary plan (`tfplan`) is the canonical artifact for deterministic apply.
- The text plan (`tfplan.txt`) is readable for reviewers, audit logs, and troubleshooting.

### Artifact Publishing

- Publishes `environments/dev/tfplan` as artifact `tfplan-dev`.
- Publishes `environments/dev/tfplan.txt` as artifact `tfplan-dev-text`.

This allows downstream pipelines or manual processes to consume exactly what was planned.

## Important Operational Notes

- `azureSubscription: "YOUR-SERVICE-CONNECTION-NAME"` must be replaced with a real Azure DevOps service connection.
- The pipeline currently does not execute `terraform apply`.
- `apply-dev.yml` naming may be intentional for future extension, but behavior today is planning/publishing only.
- `terraform init` uses the backend configuration in the environment folder; ensure backend settings and permissions are valid for CI.

## Why This Design Is Useful

- Enforces consistent Terraform runtime version.
- Uses secure service-connection auth instead of hardcoded credentials.
- Produces auditable and reusable artifacts.
- Separates planning from applying, reducing risk and supporting approvals/governance workflows.
