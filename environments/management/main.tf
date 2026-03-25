terraform {
  cloud {
    organization = "Mangrich"

    workspaces {
      name = "management"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.9"
}

# --- Providers ---

provider "hcloud" {
  token = var.hcloud_token != "" ? var.hcloud_token : null
}

provider "helm" {
  kubernetes {
    host                   = local.kubeconfig.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
    client_certificate     = base64decode(local.kubeconfig.users[0].user["client-certificate-data"])
    client_key             = base64decode(local.kubeconfig.users[0].user["client-key-data"])
  }
}

# --- Cluster k3s ---

module "management" {
  source = "../../modules/k3s-cluster"

  name            = "ubuntu-4gb-nbg1-1"
  server_type     = "cx23"
  location        = "nbg1"
  role            = "management"
  ssh_key_names   = ["costa.mangrich@gmail.com", "fllp"]
  ssh_private_key = var.ssh_private_key
}

locals {
  kubeconfig = yamldecode(module.management.kubeconfig)
}

# --- Platform apps (Helm) ---

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.8.23"

  values = [<<-YAML
    server:
      service:
        type: ClusterIP
    configs:
      params:
        server.insecure: true
  YAML
  ]

  depends_on = [module.management]
}
