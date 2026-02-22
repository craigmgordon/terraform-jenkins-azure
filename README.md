## Shared files via symlinks (`environments/_shared`)

We keep canonical shared Terraform configuration under:

- `environments/_shared/providers.tf` — Terraform/provider constraints and the `azurerm` provider block
- `environments/_shared/locals.tf` — shared naming/tag conventions and safe defaults

### Important: how Terraform loads files
Terraform only loads `.tf` files from the directory you run it in (e.g. `environments/dev`).  
It will **not** automatically load `.tf` files from `environments/_shared`.

To avoid duplication while keeping a single source of truth, we use **symlinks** from each environment folder to `_shared`.

### Symlinks in each environment folder
Each environment folder contains symlinks:
- `environments/dev/providers.tf`  → `../_shared/providers.tf`
- `environments/dev/locals.tf`     → `../_shared/locals.tf`
- `environments/prod/providers.tf` → `../_shared/providers.tf`
- `environments/prod/locals.tf`    → `../_shared/locals.tf`

This ensures updates to `_shared` automatically apply to all environments.

### Creating the symlinks
Run from repo root (Linux/macOS and CI agents):

```bash
# Dev
ln -s ../_shared/providers.tf environments/dev/providers.tf
ln -s ../_shared/locals.tf    environments/dev/locals.tf

# Prod
ln -s ../_shared/providers.tf environments/prod/providers.tf
ln -s ../_shared/locals.tf    environments/prod/locals.tf
