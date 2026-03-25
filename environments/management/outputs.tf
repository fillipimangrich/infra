output "management_ip" {
  description = "IP público do management cluster"
  value       = module.management.ipv4_address
}
