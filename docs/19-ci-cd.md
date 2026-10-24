# 19. CI/CD

The full pipeline is in [`.github/workflows/terraform.yml`](../.github/workflows/terraform.yml):

| Trigger | Jobs |
|---|---|
| Pull request | fmt check → tflint → init, validate, plan (dev + prod) |
| Merge to `main` | same as above → apply dev → **approval** → apply prod |

**Authentication with GitHub OIDC (no stored AWS keys):**

```yaml
permissions:
  contents: read
  id-token: write

steps:
  - uses: aws-actions/configure-aws-credentials@v6
    with:
      role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
      aws-region: eu-south-1
```

The IAM role and OIDC provider are created by [`bootstrap/`](../bootstrap).

**Minimal workflow** (single folder, for a small project):

```yaml
name: Terraform

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

permissions:
  contents: read
  id-token: write

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7

      - uses: aws-actions/configure-aws-credentials@v6
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: eu-south-1

      - uses: hashicorp/setup-terraform@v4
        with:
          terraform_version: "1.17.0"

      - run: terraform fmt -check -recursive
      - run: terraform init -input=false
      - run: terraform validate
      - run: terraform plan -input=false -out=tfplan

      - name: Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: terraform apply -input=false tfplan
```

---

← [Command cheat sheet](18-cli-cheat-sheet.md) · [Index](README.md) · [Best practices](20-best-practices.md) →
