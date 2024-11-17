resource "kubernetes_namespace" "cert_manager" {
    metadata {
        name = "cert-manager"
        labels = {
            "name" = "cert-manager"
        }
    }
}

resource "helm_release" "cert_manager" {
    name       = "cert-manager"
    repository = "https://charts.jetstack.io"
    chart      = "cert-manager"
    version    = "v1.12.3"
    namespace  = kubernetes_namespace.cert_manager.metadata.0.name

    set {
        name  = "installCRDs"
        value = "true"
    }
}


resource "kubernetes_manifest" "cluster_issuer" {
    manifest = {
        apiVersion = "cert-manager.io/v1"
        kind       = "ClusterIssuer"
        metadata = {
            name      = "letsencrypt-prod"
            namespace = "cert-manager"
        }
        spec = {
            acme = {
                email      = var.CLOUDFLARE_EMAIL
                server     = "https://acme-v02.api.letsencrypt.org/directory"
                privateKeySecretRef = {
                    name = "letsencrypt-prod-key"
                }
                solvers = [
                    {
                        dns01 = {
                            cloudflare = {
                                email    = var.CLOUDFLARE_EMAIL
                                apiToken = var.CLOUDFLARE_TOKEN
                            }
                        }
                    }
                ]
            }
        }
    }
    depends_on = [helm_release.cert_manager]
}
