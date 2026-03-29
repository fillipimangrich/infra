terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.49"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
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
    prevent_destroy = false
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
      "until kubectl get nodes 2>/dev/null | grep -q Ready; do sleep 2; done",
    ]
  }
}

resource "null_resource" "write_ssh_key" {
  triggers = {
    always_run = uuid()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo '${var.ssh_private_key}' > /tmp/k3s_key
      chmod 600 /tmp/k3s_key
    EOT
  }
}

data "external" "kubeconfig" {
  depends_on = [null_resource.k3s_install, null_resource.write_ssh_key]

  program = ["bash", "-c", <<-EOT
    CONTENT=$(ssh -o StrictHostKeyChecking=no -i /tmp/k3s_key root@${hcloud_server.this.ipv4_address} "cat /etc/rancher/k3s/k3s.yaml")
    echo "{\"content\": $(echo "$CONTENT" | jq -Rs .)}"
  EOT
  ]
}
