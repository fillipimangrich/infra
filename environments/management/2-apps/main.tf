terraform {
  cloud {
    organization = "Mangrich"

    workspaces {
      name = "management-apps"
    }
  }

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  required_version = ">= 1.9"
}

data "terraform_remote_state" "infra" {
  backend = "remote"

  config = {
    organization = "Mangrich"
    workspaces = {
      name = "management-infra"
    }
  }
}

locals {
  kubeconfig = yamldecode(data.terraform_remote_state.infra.outputs.kubeconfig)
}

provider "helm" {
  kubernetes {
    host                   = local.kubeconfig.clusters[0].cluster.server
    cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster["certificate-authority-data"])
    client_certificate     = base64decode(local.kubeconfig.users[0].user["client-certificate-data"])
    client_key             = base64decode(local.kubeconfig.users[0].user["client-key-data"])
  }
}

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
}
