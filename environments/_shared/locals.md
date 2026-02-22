# locals.tf — Shared locals (naming, tags, defaults)

## Purpose
`locals.tf` centralises conventions used across environments:
- standard naming (`name_prefix`)
- common tagging (`common_tags`)
- default values and helper locals that reduce repetition

This helps keep resource naming consistent and ensures every resource is tagged in the same way (critical for governance/cost reporting).

## What it does
Typical locals defined here include:

### 1) Standard tags
A merged tag set applied everywhere, usually including:
- `project`
- `environment`
- `owner`
- `managed_by`
- `costcentre` (if the client uses it)
- plus any extra tags passed in `var.tags`

### 2) Name prefix convention
A consistent prefix such as:
- `${var.name}-${var.environment}`

This makes it easy to identify resources and avoids naming drift between modules/environments.

### 3) Optional defaults
You can also keep safe, non-secret defaults here, for example:
- Jenkins container image tag (e.g. `jenkins/jenkins:lts-jdk17`)
- ports (8080 / 50000)
- mount point (`/var/jenkins_home`)
- disk LUN (`0`)

## Why use locals instead of variables everywhere?
Locals are good for:
- derived values (like a `name_prefix`)
- standard conventions that should not vary per module
- keeping environment `main.tf` files small and readable

Use variables when the value must be:
- configurable per environment
- provided externally (tfvars/pipeline variables)
- secret or sensitive (never put secrets in locals)

## Important note about Terraform file loading
Terraform only loads `.tf` files from the directory you run it in (e.g., `environments/dev`).

If `locals.tf` lives under `environments/_shared`, it will **not** be read automatically unless you:
1) copy it into each environment folder, or
2) symlink it into each environment folder.

### Recommended approach (simple and reliable)
Copy the content into:
- `environments/dev/locals.tf`
- `environments/prod/locals.tf`

Alternatively, if your team is comfortable with symlinks, symlink the shared file into each environment folder.

## Suggested guardrails
- Don’t put secrets in `locals.tf` (they may end up in state or logs).
- Keep locals focused on conventions (naming/tags/defaults), not large configuration blobs.
- If a “default” starts diverging per environment, promote it to an environment variable (tfvars).
