output "server_id" {
  description = "ID da VM na Hetzner"
  value       = hcloud_server.this.id
}

output "ipv4_address" {
  description = "IP público da VM"
  value       = hcloud_server.this.ipv4_address
}

output "name" {
  description = "Nome da VM"
  value       = hcloud_server.this.name
}

output "kubeconfig" {
  description = "Kubeconfig do cluster com IP público"
  value = replace(
    data.external.kubeconfig.result.content,
    "127.0.0.1",
    hcloud_server.this.ipv4_address
  )
  sensitive = true
  depends_on = [null_resource.k3s_install]
}
