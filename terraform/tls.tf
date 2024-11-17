module "cert_manager" {
    source = "terraform-iaac/cert-manager/kubernetes"
    namespace = "cert-manager"
    create_namespace = true

    name = "cert-manager"
    chart = "https://charts.jetstack.io"
    target_revision = "v1.15.2"

    install_crd = true
    create_ingress = false
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
