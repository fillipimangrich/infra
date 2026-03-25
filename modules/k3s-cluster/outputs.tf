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
