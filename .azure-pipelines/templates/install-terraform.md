# install-terraform.yml — Template documentation

## What it does
`install-terraform.yml` is a small Azure Pipelines template that installs a specific Terraform version on the pipeline agent (typically `ubuntu-latest`), adds it to the PATH, and prints `terraform version` so you can confirm exactly what is running.

## Why it exists
Terraform behaviour can vary slightly between versions. Pinning a version in CI/CD helps you avoid:
- “Works on my machine” issues
- unplanned drift from hosted agents that might already have a different Terraform version
- inconsistent plans/applies between dev/prod pipelines

Using a template instead of repeating install steps in every pipeline:
- keeps YAML smaller and easier to read
- ensures every pipeline uses the same install approach
- makes upgrades easy (change one place)

## Parameters
- `terraformVersion` (string, default: `1.6.6`)
  - The Terraform version to download and install from HashiCorp releases.

## Inputs / outputs
### Inputs
- None (aside from the version parameter).

### Outputs
- Terraform installed in `/usr/local/bin/terraform`
- `terraform version` printed to logs for traceability

## Typical usage
In a pipeline YAML:

```yaml
- template: templates/install-terraform.yml
  parameters:
    terraformVersion: "1.6.6"