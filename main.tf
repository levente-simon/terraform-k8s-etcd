terraform { }

provider "kubernetes" {
  host                   = var.k8s_host
  client_certificate     = var.k8s_client_certificate
  client_key             = var.k8s_client_key
  cluster_ca_certificate = var.k8s_cluster_ca_certificate
  token                  = var.k8s_cluster_client_token
}

provider "helm" {
  kubernetes {
    host                   = var.k8s_host
    client_certificate     = var.k8s_client_certificate
    client_key             = var.k8s_client_key
    cluster_ca_certificate = var.k8s_cluster_ca_certificate
    token                  = var.k8s_cluster_client_token
  }
}

variable "module_depends_on" {
  type    = any
  default = []
}

resource "kubernetes_namespace" "etcd" {
  depends_on = [ var.module_depends_on ]

  lifecycle {
    ignore_changes  = all 
  }

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_manifest" "cert_etcd_client" {
  depends_on = [ kubernetes_namespace.etcd ]

  manifest   = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata"   = {
      "name"        = "etcd-client"
      "namespace"   = "${var.namespace}"
    }
    "spec"       = {
      "secretName"  = "etcd-client-tls"
      "duration"    = "12h0m0s"
      "renewBefore" = "2h0m0s"
      "subject"     = {
        "organizations" = [ "Corp" ]
      }
      "privateKey"  = {
        "algorithm"     = "RSA"
        "encoding"      = "PKCS1"
        "size"          = "2048"
      }
      "usages"      = [ "server auth"  ]
      "dnsNames"    = [ "${var.etcd_fqdn}", "*.etcd-headless.etcd.svc.cluster.local" ]
      "issuerRef"   = { 
        "name"  = "vault-issuer"
        "kind"  = "ClusterIssuer"
      }
    }
  }
}

resource "kubernetes_manifest" "cert_etcd_peer" {
  depends_on = [ kubernetes_namespace.etcd ]

  manifest   = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata"   = {
      "name"        = "etcd-peer"
      "namespace"   = "${var.namespace}"
    }
    "spec"       = {
      "secretName"  = "etcd-peer-tls"
      "duration"    = "12h0m0s"
      "renewBefore" = "2h0m0s"
      "subject"     = {
        "organizations" = [ "Corp" ]
      }
      "privateKey"  = {
        "algorithm"     = "RSA"
        "encoding"      = "PKCS1"
        "size"          = "2048"
      }
      "usages"      = [ "server auth", "client auth" ]
      "dnsNames"    = [ "*.etcd-headless.etcd.svc.cluster.local" ]
      "issuerRef"   = { 
        "name"  = "vault-issuer"
        "kind"  = "ClusterIssuer"
      }
    }
  }
}

resource "helm_release" "etcd" {
  depends_on = [ kubernetes_namespace.etcd ]
  name       = "etcd"

  lifecycle {
    ignore_changes  = all 
  }

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "etcd"
  namespace  = var.namespace
  values     = [ "${format(file("${path.module}/etc/etcd-config.yaml"),
                     var.etcd_fqdn,
                     var.rootpwd)}"
               ]
}
