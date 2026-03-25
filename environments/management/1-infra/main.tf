terraform {
  cloud {
    organization = "Mangrich"

    workspaces {
      name = "management-infra"
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
  }

  required_version = ">= 1.9"
}

provider "hcloud" {
  token = var.hcloud_token != "" ? var.hcloud_token : null
}

module "management" {
  source = "../../../modules/k3s-cluster"

  name            = "ubuntu-4gb-nbg1-1"
  server_type     = "cx23"
  location        = "nbg1"
  role            = "management"
  ssh_key_names   = ["costa.mangrich@gmail.com", "fllp"]
  ssh_private_key = var.ssh_private_key
}
