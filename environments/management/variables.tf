variable "hcloud_token" {
  description = "Token da API da Hetzner Cloud"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_private_key" {
  description = "Chave privada SSH para provisionar VMs"
  type        = string
  sensitive   = true
  default     = ""
}
