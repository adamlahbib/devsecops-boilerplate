resource "helm_release" "tailscale_operator" {
    name = "tailscale-operator"
    repository = "https://pkgs.tailscale.com/helmcharts"
    chart = "tailscale-operator"
    namespace = "tailscale"
    create_namespace = true

    set {
        name = "oauth.clientId"
        value = var.TAILSCALE_CLIENT_ID
    }

    set {
        name = "oauth.clientSecret"
        value = var.TAILSCALE_CLIENT_SECRET
    }

    set {
        name = "operatorConfig.hostname"
        value = "${var.project_name}-operator"
    }
}