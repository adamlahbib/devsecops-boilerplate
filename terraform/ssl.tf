resource "helm_release" "cert_manager" {
    name       = "cert-manager"
    repository = "https://charts.jetstack.io"
    chart      = "cert-manager"

    set {
        name  = "installCRDs"
        value = "true"
    }
}

resource "kubernetes_namespace" "cert_manager" {
    metadata {
        name = "cert-manager"
    }
}

resource "kubernetes_certificate" "cluster_issuer" {
    metadata {
        name      = "letsencrypt-prod"
        namespace = "cert-manager"
    }
    spec {
    acme {
            email      = var.CLOUDFLARE_EMAIL
            server     = "https://acme-v02.api.letsencrypt.org/directory"
            privateKeySecretRef {
            name = "letsencrypt-prod-key"
        }
        solvers {
            dns01 {
                cloudflare {
                    email    = var.CLOUDFLARE_EMAIL
                    apiToken = var.CLOUDFLARE_TOKEN
                }
            }
        }
    }
    }
}
