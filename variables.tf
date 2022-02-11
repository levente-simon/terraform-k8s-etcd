variable "k8s_host"                   { type = string }
variable "k8s_client_certificate"     { type = string }
variable "k8s_client_key"             { type = string }
variable "k8s_cluster_ca_certificate" { type = string }

variable "namespace"                  { type = string }
variable "etcd_fqdn"                  { type = string }
variable "rootpwd"                    { type = string }
