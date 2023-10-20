terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = ">= 2.30.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11.0"
    }
  }

  required_version = ">= 1.5.0"
}

variable "profile" {
  type        = string
  description = "Profile to use"
  default     = "srr"
}

variable "region" {
  type        = string
  description = "multiaz region"
  default     = "fr-srr"
}

variable "zone" {
  type        = string
  description = "multiaz zone"
  default     = "fr-srr-1"
}

provider "scaleway" {
  region  = var.region
  zone    = var.zone
  profile = var.profile
}

provider "kubernetes" {
  alias                  = "multiaz"
  host                   = scaleway_k8s_cluster.kapsule.kubeconfig[0].host
  token                  = scaleway_k8s_cluster.kapsule.kubeconfig[0].token
  cluster_ca_certificate = base64decode(scaleway_k8s_cluster.kapsule.kubeconfig[0].cluster_ca_certificate)
}

provider "kubectl" {
  alias                  = "multiaz"
  host                   = scaleway_k8s_cluster.kapsule.kubeconfig[0].host
  token                  = scaleway_k8s_cluster.kapsule.kubeconfig[0].token
  cluster_ca_certificate = base64decode(scaleway_k8s_cluster.kapsule.kubeconfig[0].cluster_ca_certificate)
  load_config_file       = false
}

provider "helm" {
  alias = "multiaz"
  kubernetes {
    host                   = scaleway_k8s_cluster.kapsule.kubeconfig[0].host
    token                  = scaleway_k8s_cluster.kapsule.kubeconfig[0].token
    cluster_ca_certificate = base64decode(scaleway_k8s_cluster.kapsule.kubeconfig[0].cluster_ca_certificate)
  }
}
