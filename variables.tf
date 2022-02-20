variable "namespace"                  { type = string }
variable "etcd_fqdn"                  { type = string }

variable "rootpwd" {
  type      = string
  sensitive = true
}

variable "k8s_host" {
  type      = string
  sensitive = true
}

variable "k8s_client_certificate" {
  type      = string
  sensitive = true
  default   = ""
}

variable "k8s_client_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "k8s_cluster_ca_certificate" {
  type      = string
  sensitive = true
  default   = ""
}

variable "k8s_cluster_client_token" {
  type      = string
  sensitive = true
  default   = ""
}
