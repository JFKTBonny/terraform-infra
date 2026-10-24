# terraform-infra

AWS infrastructure managed with Terraform, plus a practical Terraform guide.

- **Learn Terraform:** [docs/](docs/README.md) (20 short topic files)
- **Smallest working example:** [examples/01-single-ec2](examples/01-single-ec2)
- **User data and provisioners:** [examples/02-user-data-and-provisioners](examples/02-user-data-and-provisioners)
- **Real layout (modules + environments + CI):** the rest of this repo

## Repository layout

```
terraform-infra/
├── .github/workflows/terraform.yml   # CI: fmt, lint, plan on PR, apply on merge
├── bootstrap/                        # one-time: state bucket + GitHub OIDC role
├── docs/                             # Terraform guide, one file per topic
├── environments/
│   ├── dev/                          # dev config + its own state
│   └── prod/                         # prod config + its own state
├── examples/
│   ├── 01-single-ec2/                # smallest standalone example
│   └── 02-user-data-and-provisioners/ # cloud-init, local-exec, remote-exec, file
├── modules/
│   ├── network/                      # VPC, public subnets, IGW, routes
│   └── web-server/                   # EC2 + nginx + security group
├── .gitignore
├── .pre-commit-config.yaml
├── .terraform-version
├── .tflint.hcl
└── Makefile
```

| Folder | Purpose |
|---|---|
| `bootstrap/` | Creates the S3 state bucket and the IAM role CI uses. Run once, by hand. |
| `modules/` | Reusable building blocks. No `provider` or `backend` blocks. |
| `environments/<env>/` | Calls the modules. Each has its own state file and `terraform.tfvars`. |
| `examples/` | Self-contained learning projects with local state. |

## Prerequisites

| Tool | Version |
|---|---|
| Terraform | >= 1.11 (CI uses 1.17.0, see `.terraform-version`) |
| AWS CLI | v2, logged in (`aws configure` or `aws sso login`) |
| tflint | optional, for `make lint` |
| pre-commit | optional, for local git hooks |

> **Region:** this repo uses `eu-south-1` (Milan). It is an opt-in region: enable it in
> **AWS Console → Account → AWS Regions** first, or replace `eu-south-1` everywhere
> (`grep -rn eu-south-1 .`) with a default region such as `eu-central-1`.

## Setup (once)

### 1. Bootstrap the state bucket and CI role

```bash
cd bootstrap
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars: bucket name, GitHub owner and repo
terraform init
terraform apply
terraform output
cd ..
```

### 2. Point the environments at the bucket

Replace `mycompany-terraform-state-12345` with your bucket name:

```bash
grep -rl "mycompany-terraform-state-12345" environments bootstrap/backend.tf.example | xargs sed -i.bak "s/mycompany-terraform-state-12345/YOUR-BUCKET-NAME/g"
find . -name "*.bak" -delete
```

### 3. Edit environment values

Edit `environments/dev/terraform.tfvars` and `environments/prod/terraform.tfvars`
(set `allowed_ssh_cidrs` to your own IP: `curl -s https://checkip.amazonaws.com`).

### 4. First deploy from your machine

```bash
make plan ENV=dev
make apply ENV=dev
make output ENV=dev
```

### 5. Configure GitHub

1. **Settings → Secrets and variables → Actions → New repository secret**
   - `AWS_ROLE_ARN` = value of `terraform output github_actions_role_arn` from `bootstrap/`
2. **Settings → Environments:** create `dev` and `prod`.
   On `prod`, enable **Required reviewers**.
3. **Settings → Branches → Add rule for `main`:** require a pull request and
   require the status checks to pass.

### 6. Push

```bash
git init
git add .
git commit -m "Initial Terraform structure"
git branch -M main
git remote add origin https://github.com/<your-user>/terraform-infra.git
git push -u origin main
```

Commit the `.terraform.lock.hcl` files that `terraform init` creates.

## Daily workflow

```bash
git checkout -b feature/my-change
# edit code
make fmt
make plan ENV=dev
git add . && git commit -m "Describe the change"
git push -u origin feature/my-change
```

1. Open a pull request → CI runs format check, tflint, validate, and plan for dev and prod.
2. Review the plan in the job summary.
3. Merge → CI applies **dev**, then waits for approval and applies **prod**.

## Make targets

| Command | What it does |
|---|---|
| `make help` | List targets |
| `make fmt` | Format all files |
| `make lint` | Run tflint |
| `make plan ENV=dev` | Init and plan, save to `tfplan` |
| `make apply ENV=dev` | Apply the saved plan |
| `make output ENV=dev` | Show outputs |
| `make destroy ENV=dev` | Destroy the environment |
| `make clean` | Remove `.terraform/` folders and plan files |

## Adding a new environment

```bash
mkdir environments/staging
cp environments/dev/{versions,main,variables,outputs}.tf environments/staging/
cp environments/dev/backend.tf environments/dev/terraform.tfvars environments/staging/
sed -i.bak 's#key          = "dev/#key          = "staging/#' environments/staging/backend.tf
rm environments/staging/backend.tf.bak
# edit environments/staging/terraform.tfvars: environment = "staging", new vpc_cidr
```

Then add `staging` to the `matrix.environment` list in `.github/workflows/terraform.yml`.

## Tear down

```bash
make destroy ENV=prod
make destroy ENV=dev
```

The state bucket has `prevent_destroy = true`. To delete it, remove that line in
`bootstrap/main.tf`, empty the bucket, then run `terraform destroy` in `bootstrap/`.

## Security notes

- CI authenticates with **GitHub OIDC**: no long-lived AWS keys are stored in GitHub.
- The bootstrap role uses `AdministratorAccess` for simplicity. Scope it down for real use.
- Never commit secrets. Use AWS Secrets Manager or SSM Parameter Store and read them with data sources.
