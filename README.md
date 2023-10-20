# Terraform examples

This repository contains a few examples to deploy Scaleway Kapsule clusters:

| Directory      | Description                                                                             |
| -------------- | --------------------------------------------------------------------------------------- |
| `prd/default`  | A basic kapsule cluster                                                                 |
| `prd/multi-az` | A production ready multi-az kapsule cluster                                             |
| `prd/pgw`      | A basic kapsule cluster with fully isolated nodes (no public ip) using a public gateway |

## Deployment

1. Install the Scaleway CLI and initialize the configuration.

* `pacman -S scaleway-cli`
* `scw init`

> You may use profiles to differentiate between accounts/orgs/projects.

2. Go into any directory depending on which config you want to use (ex: `cd prd/multi-az`)
3. Edit the `terraform.tfvars` file
4. `terraform init` - Initializes terraform
5. `terraform apply` - Deploy the environment
