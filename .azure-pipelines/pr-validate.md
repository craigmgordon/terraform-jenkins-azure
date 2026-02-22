# PR Validation Pipeline (`pr-validate.yml`)

This file defines an Azure Pipelines job that runs on every pull request. Its purpose is to provide fast, consistent Terraform checks before merge, without touching any real backends or cloud resources.

## What It Does

The pipeline runs a series of Terraform quality gates:

- Installs a pinned Terraform version so every PR is validated with the same binary.
- Checks that all Terraform files are formatted consistently across the repository.
- Runs `terraform validate` in `environments/dev` and `environments/prod` using a local, non-backend initialization.

These steps are all read-only and safe to run on PRs.

## Why Each Step Exists

### Triggering

- `trigger: none` disables CI runs on pushes. This keeps the pipeline focused only on PR validation.
- `pr.branches.include: "*"` enables the pipeline for PRs targeting any branch.

### Agent Pool

- `pool.vmImage: ubuntu-latest` uses a standard Microsoft-hosted Linux image. This keeps Terraform installs and shell scripts predictable.

### Variables

- `TF_VERSION: "1.6.6"` pins Terraform to a known version. This prevents differences caused by developer machines or future Terraform releases.

### Steps

1. `checkout: self`
   - Pulls the repo content so the pipeline can validate it.

2. **Install Terraform**
   - If Terraform is already present, it prints the version.
   - If not, it downloads the exact pinned version and installs it into `/usr/local/bin`.
   - This avoids relying on whatever is bundled with the runner image.

3. **Terraform format check (repo)**
   - Runs `terraform fmt -check -recursive` on the whole repo.
   - Ensures formatting is consistent and fails the build if changes would be needed.
   - This keeps diffs clean and predictable.

4. **Terraform validate (environments/dev)**
   - `cd environments/dev`
   - `terraform init -backend=false -input=false` initializes without any backend or prompts.
   - `terraform validate -no-color` checks the configuration for syntax and internal consistency.

5. **Terraform validate (environments/prod)**
   - Same process as `dev`, but against `environments/prod`.
   - Confirms both environments are structurally correct before merge.

## Safety and Scope

- No state backends are contacted because `-backend=false` is used.
- No Terraform `plan` or `apply` is run.
- This pipeline only verifies formatting and correctness, making it safe for all PRs.

## When to Update This File

- If you standardize a different Terraform version, update `TF_VERSION`.
- If you add new environments, mirror the `validate` step for each new folder.
- If you add linters or security tools, append them as additional Bash steps.
