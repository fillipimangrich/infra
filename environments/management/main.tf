terraform {
  cloud {
    organization = "Mangrich"

    workspaces {
      name = "kube-test"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
  }

  required_version = ">= 1.9"
}

provider "hcloud" {
  token = var.hcloud_token
}
