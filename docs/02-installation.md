# 2. Installation

**macOS (Homebrew):**

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
terraform -version
```

**Ubuntu / Debian:**

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common wget
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
terraform -version
```

**Windows (winget):**

```powershell
winget install --id Hashicorp.Terraform -e
terraform -version
```

**Windows (Chocolatey):**

```powershell
choco install terraform
terraform -version
```

**Version manager (switch versions per project):**

```bash
brew install tfenv          # macOS; on Linux: git clone https://github.com/tfutils/tfenv.git ~/.tfenv
tfenv install 1.17.0
tfenv use 1.17.0
```

`tfenv` reads the `.terraform-version` file in the repo root automatically.

**Shell autocomplete:**

```bash
terraform -install-autocomplete
```

---

← [What Terraform is](01-what-is-terraform.md) · [Index](README.md) · [Core concepts](03-core-concepts.md) →
