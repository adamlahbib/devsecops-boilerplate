resource "helm_release" "cert_manager" {
    name       = "cert-manager"
    repository = "https://charts.jetstack.io"
    chart      = "cert-manager"
    version    = "v1.12.3"
    namespace  = "cert-manager"
    create_namespace = true

    set {
        name  = "installCRDs"
        value = "true"
    }
}

resource "kubernetes_secret" "cloudflare_api_token" {
    metadata {
        name      = "cloudflare-api-token"
        namespace = "cert-manager"
    }
    data = {
        api-token = base64encode(var.CLOUDFLARE_API_TOKEN)
    }
}

resource "kubectl_manifest" "cluster_issuer" {
    yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: cert-manager
spec:
    acme:
        email: ${var.CLOUDFLARE_EMAIL}
        server: https://acme-v02.api.letsencrypt.org/directory
        privateKeySecretRef:
        name: letsencrypt-prod-key
        solvers:
        - dns01:
            cloudflare:
            email: ${var.CLOUDFLARE_EMAIL}
            apiTokenSecretRef:
                name: cloudflare-api-token
                key: api-token
YAML
    depends_on = [helm_release.cert_manager, kubernetes_secret.cloudflare_api_token]
}
