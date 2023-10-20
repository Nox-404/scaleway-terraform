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

## Configurations

| Config     | Isolated Nodes     | Nodes with Public IPs | Public Gateway     | Multi-AZ           | Ingress controller | Cert-Manager       |
| ---------- | ------------------ | --------------------- | ------------------ | ------------------ | ------------------ | ------------------ |
| `default`  | :white_check_mark: | :white_check_mark:    | :x:                | :x:                | :white_check_mark: | :white_check_mark: |
| `multi-az` | :white_check_mark: | :white_check_mark:    | :x:                | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| `pgw`      | :white_check_mark: | :x:                   | :white_check_mark: | :x:                | :white_check_mark: | :white_check_mark: |

* **CNI**: `cilium`
* **Auto Upgrade** - Enabled on all `clusters` on a weekly basis.
* **Auto Heal** - Enabled on all `pools`, will auto-replace failing nodes.
* **Auto Scale** - Enabled on all `pools`, from `2` to `3` nodes per pool.
* **Placement group** - Enabled to enhance the availability of nodes.

> Note: the placement group **limits the pools to 20 Instances**, you may want to remove the placement groups if you need more nodes per pools.

## Services

### Ingress-Controller

The ingress controller uses an `ingress-nginx` deployed as a `DaemonSet`.  
It uses `Proxy-Protocol-V2` to expose the client IP in the `X-Forwarded-For` header.

The `multi-az` configuration uses multiple `LoadBalancer` services so that you can use **DNS Round Robin** to enhance the availability. (failure of an entire AZ)

> DNS is not handled by this terraform but could be added too.

### Cert-Manager

A `certmanager` is deployed in the clusters, allowing you to sign certificate with letsencript.
