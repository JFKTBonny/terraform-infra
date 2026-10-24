# 20. Best practices

**State**
- Use a remote backend with locking (`use_lockfile = true` on S3), versioning, and encryption.
- One state per environment (and per large component), so a mistake can't reach everything.
- Never edit or commit state. Use `moved` / `removed` / `import` blocks for refactoring.

**Versions**
- Pin Terraform (`required_version`), providers (`~> 6.0`), and modules (`version` or `?ref=`).
- Commit `.terraform.lock.hcl`. Upgrade on purpose with `terraform init -upgrade`.

**Code**
- Prefer `for_each` over `count` when items have identities.
- Keep modules small, single-purpose, without `provider` / `backend` blocks.
- Validate inputs with `validation` blocks; describe every variable and output.
- Tag everything (`default_tags` on AWS).
- Configure servers with user data / cloud-init or a pre-built image; use provisioners only as a last resort.

**Security**
- No secrets in `.tf` or committed `.tfvars`. Use Secrets Manager / SSM / Vault and mark variables `sensitive = true`.
- Remember: sensitive values are still stored in state — restrict who can read the state bucket.
- Use OIDC for CI instead of long-lived access keys; grant least-privilege IAM.
- Scan code with `tflint`, `checkov`, or `trivy config`.

**Process**
- Always review `plan` before `apply`; in CI apply the **saved** plan.
- Run `fmt`, `validate`, lint, and plan on every pull request.
- Require approval for production applies (GitHub Environments).
- Don't change Terraform-managed resources in the cloud console; it causes drift. Check with `terraform plan -refresh-only`.

---

← [CI/CD](19-ci-cd.md) · [Index](README.md)
