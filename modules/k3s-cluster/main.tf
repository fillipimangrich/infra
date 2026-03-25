terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
  }
}

resource "hcloud_server" "this" {
  name        = var.name
  server_type = var.server_type
  image       = "ubuntu-24.04"
  location    = var.location
  ssh_keys    = var.ssh_key_names

  labels = {
    role = var.role
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "null_resource" "k3s_install" {
  depends_on = [hcloud_server.this]

  triggers = {
    server_id = hcloud_server.this.id
  }

  connection {
    type        = "ssh"
    host        = hcloud_server.this.ipv4_address
    user        = "root"
    private_key = var.ssh_private_key
  }

  provisioner "remote-exec" {
    inline = [
      "apt-get update -qq",
      "curl -sfL https://get.k3s.io | sh -",
      "systemctl enable k3s",
      "systemctl start k3s",
    ]
  }
}
