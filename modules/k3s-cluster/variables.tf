variable "name" {
  description = "Nome da VM na Hetzner"
  type        = string
}

variable "server_type" {
  description = "Tipo da VM na Hetzner (ex: cx23, cx32)"
  type        = string
  default     = "cx23"
}

variable "location" {
  description = "Localização da VM na Hetzner (ex: nbg1, fsn1, hel1)"
  type        = string
  default     = "nbg1"
}

variable "role" {
  description = "Role da VM — usado como label (ex: management, workload)"
  type        = string
}

variable "ssh_key_names" {
  description = "Lista de nomes das chaves SSH cadastradas na Hetzner"
  type        = list(string)
  default     = []
}
