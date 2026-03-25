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
  token = var.hcloud_token != "" ? var.hcloud_token : null
}

resource "hcloud_server" "management" {
  name        = "ubuntu-4gb-nbg1-1"
  server_type = "cx23"
  image       = "ubuntu-24.04"
  location    = "nbg1"

  labels = {
    role = "management"
  }
}
