# terraform-job.yml — Template documentation

## Purpose
`terraform-job.yml` is an Azure Pipelines **job template** that standardises running Terraform against a specific environment folder (e.g. `environments/dev`). It’s intended to reduce duplication across pipelines and enforce consistent Terraform practices.

It supports the common lifecycle actions:
- `validate`
- `plan`
- `apply`
- `destroy`

## What it does

### validate
- Changes directory to `workingDirectory`
- Runs:
  - `terraform init -backend=false -input=false`
  - `terraform validate -no-color`

Use this for PR checks where you don’t want to depend on Azure credentials or remote state access.

### plan
- Authenticates to Azure via an Azure DevOps **service connection** (AzureCLI@2 with `addSpnToEnvironment: true`)
- Exports `ARM_*` environment variables so the `azurerm` provider can authenticate
- Runs:
  - `terraform init -input=false` (or backend-less init if `backend: false`)
  - `terraform plan -out <planFile>` (optionally with `-var-file`)
  - `terraform show -no-color <planFile> > tfplan.txt`
- Optionally publishes artifacts:
  - `<planFile>` (binary plan)
  - `tfplan.txt` (human-readable plan output)

### apply
- Authenticates to Azure as above
- Runs apply in one of two modes:
  1) **Preferred**: apply an existing saved plan file (promoted from a prior plan step):
     - `terraform apply -auto-approve <applyPlanPath>`
  2) **Fallback**: apply directly from configuration:
     - `terraform apply -auto-approve -var-file=...`

### destroy
- Authenticates to Azure as above
- Runs:
  - `terraform destroy -auto-approve` (optionally with `-var-file`)

## Why this template exists
Terraform pipelines tend to repeat the same steps across environments:
- install Terraform
- authenticate to Azure
- init with backend
- plan/apply/destroy
- produce and publish plans

Copy/pasting that logic into multiple pipeline YAMLs leads to:
- drift (dev/prod behave differently)
- inconsistent flags and output
- higher maintenance overhead

This template centralises those steps so:
- environment pipelines are short and readable
- plan/apply flows are consistent
- you can update behaviour once in one place

## Best practices baked in

### Folder = stack
Terraform executes against a **directory**, not an individual `.tf` file. The environment folder (e.g. `environments/dev`) is the unit of execution and state.

### Plan → review → apply the same plan
For production-grade workflows:
- `plan` publishes a plan artifact
- `apply` consumes that same artifact
This improves auditability and reduces surprises.

### Backend-less validation for PRs
PR validation shouldn’t require state or cloud access; `validate` uses `-backend=false`.

### Azure authentication via service connection
For non-validate actions, the template uses AzureCLI@2 and exports:
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`

This is the standard non-interactive auth path for Terraform’s `azurerm` provider in CI.

## Parameters

### Common parameters
- `name` (string): display name for the job
- `azureSubscription` (string): Azure DevOps service connection name (required for plan/apply/destroy)
- `workingDirectory` (string): folder to run Terraform in (e.g. `environments/dev`)
- `action` (string): one of `validate | plan | apply | destroy`
- `varFile` (string): tfvars file name within `workingDirectory` (optional)
- `backend` (bool): whether to use the remote backend during init (default `true`)
- `planFile` (string): output plan filename (default `tfplan`)

### Artifact parameters (plan)
- `publishPlanArtifact` (bool): publish plan artifacts (default `true`)
- `planArtifactName` (string): artifact name (e.g. `tfplan-dev`)

### Apply parameters
- `applyPlanPath` (string): path to a downloaded plan file (preferred apply mode)

### Escape hatches
- `extraInitArgs`, `extraPlanArgs`, `extraApplyArgs`, `extraDestroyArgs`

## Example usage

### Plan (dev)
```yaml
- template: templates/terraform-job.yml
  parameters:
    name: "Terraform Plan (dev)"
    azureSubscription: "YOUR-SERVICE-CONNECTION"
    workingDirectory: "environments/dev"
    action: "plan"
    varFile: "dev.tfvars"
    planArtifactName: "tfplan-dev"