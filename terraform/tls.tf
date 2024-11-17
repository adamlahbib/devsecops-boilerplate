resource "kubernetes_namespace" "cert_manager" {
    metadata {
        name = "cert-manager"
        labels = {
            "name" = "cert-manager"
        }
    }
}


module "cert_manager" {
    source = "terraform-iaac/cert-manager/kubernetes"
    cluster_issuer_email = var.CLOUDFLARE_EMAIL
    cluster_issuer_name = "letsencrypt-prod"
    cluster_issuer_private_key_secret_name = "letsencrypt-prod-key"
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
    depends_on = [module.cert_manager]
}
