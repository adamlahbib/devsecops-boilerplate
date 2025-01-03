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
    depends_on = [aws_eks_node_group.eks_nodes]
}

resource "kubernetes_secret" "cloudflare_api_token" {
    metadata {
        name      = "cloudflare-api-token"
        namespace = "cert-manager"
    }
    data = {
        api-token = var.CLOUDFLARE_API_TOKEN
    }
    depends_on = [helm_release.cert_manager]
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
            name: letsencrypt-prod
        solvers:
        - dns01:
            cloudflare:
                apiTokenSecretRef:
                    name: cloudflare-api-token
                    key: api-token
YAML
    depends_on = [helm_release.cert_manager, kubernetes_secret.cloudflare_api_token]
}
