# Terraform Guide

Reviewed October 2026. Versions used in this repo: Terraform 1.17, AWS provider 6.x.

Read in order if you are new to Terraform, or jump to a topic.

## Basics

| # | Topic | File |
|---|---|---|
| 1 | [What Terraform is](01-what-is-terraform.md) | `01-what-is-terraform.md` |
| 2 | [Installation](02-installation.md) | `02-installation.md` |
| 3 | [Core concepts](03-core-concepts.md) | `03-core-concepts.md` |
| 4 | [Project files](04-project-files.md) | `04-project-files.md` |
| 5 | [First project](05-first-project.md) | `05-first-project.md` |

## Language

| # | Topic | File |
|---|---|---|
| 6 | [Variables](06-variables.md) | `06-variables.md` |
| 7 | [Locals](07-locals.md) | `07-locals.md` |
| 8 | [Loops and conditionals](08-loops-and-conditionals.md) | `08-loops-and-conditionals.md` |
| 9 | [Data sources](09-data-sources.md) | `09-data-sources.md` |
| 16 | [Built-in functions](16-functions.md) | `16-functions.md` |

## Infrastructure patterns

| # | Topic | File |
|---|---|---|
| 10 | [State and remote backends](10-state-and-backends.md) | `10-state-and-backends.md` |
| 11 | [Modules](11-modules.md) | `11-modules.md` |
| 12 | [Multiple environments](12-multiple-environments.md) | `12-multiple-environments.md` |
| 13 | [Lifecycle, dependencies and validation](13-lifecycle-and-validation.md) | `13-lifecycle-and-validation.md` |
| 14 | [User data and provisioners](14-user-data-and-provisioners.md) | `14-user-data-and-provisioners.md` |
| 15 | [Import and refactoring](15-import-and-refactoring.md) | `15-import-and-refactoring.md` |

## Quality and delivery

| # | Topic | File |
|---|---|---|
| 17 | [Testing](17-testing.md) | `17-testing.md` |
| 18 | [Command cheat sheet](18-cli-cheat-sheet.md) | `18-cli-cheat-sheet.md` |
| 19 | [CI/CD](19-ci-cd.md) | `19-ci-cd.md` |
| 20 | [Best practices](20-best-practices.md) | `20-best-practices.md` |

## Related examples

| Example | Topics |
|---|---|
| [01-single-ec2](../examples/01-single-ec2) | [First project](05-first-project.md) |
| [02-user-data-and-provisioners](../examples/02-user-data-and-provisioners) | [User data and provisioners](14-user-data-and-provisioners.md) |
| [environments/](../environments) + [modules/](../modules) | [Modules](11-modules.md), [Multiple environments](12-multiple-environments.md), [State and remote backends](10-state-and-backends.md) |
