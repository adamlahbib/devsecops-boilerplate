resource "helm_release" "loki" {
    name       = "loki"
    repository = "https://grafana.github.io/helm-charts"
    chart      = "loki-stack"
    namespace  = "monitoring"
    create_namespace = true
    version    = "2.10.2"

    set {
        name  = "promtail.enabled"
        value = "true"
    }

    set {
        name  = "loki.persistence.enabled"
        value = "false" 
    }

    set {
        name  = "promtail.persistence.enabled"
        value = "false"  
    }
}

resource "helm_release" "tempo" {
    name      = "tempo"
    repository = "https://grafana.github.io/helm-charts"
    chart     = "tempo"
    namespace = "monitoring"
    create_namespace = true
    version   = "1.14.0"
}

resource "helm_release" "prometheus_operator" {
    name       = "prometheus-operator"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "kube-prometheus-stack"
    namespace  = "monitoring"
    create_namespace = true
    version    = "66.2.1"

    values = [yamlencode({
        grafana= {
            enabled = true
            service = {
                type = "ClusterIP"
            }
            "grafana.ini" = {
                server = {
                    root_url = "https://grafana.${var.tailnet}/"
                    domain = "grafana.${var.tailnet}"
                    serve_from_sub_path = true
                    cookie_samesite = "none"
                    cookie_secure = true
                }
            }
            adminPassword = var.GRAFANA_ADMIN_PASSWORD
            additionalDataSources = [
                {
                    name = "Prometheus"
                    type = "prometheus"
                    access = "proxy"
                    url = "http://prometheus-operated:9090"
                    isDefault = true
                }
            ]
        }
    })]

    set {
        name  = "alertmanager.enabled"
        value = "true"
    }
}

resource "kubernetes_config_map" "grafana_dashboards" {
    metadata {
        name     = "grafana-dashboards"
        namespace = "monitoring"
        labels = {
            grafana_dashboard = "1"
        }
    }
    data = {
        "21419.json" = file("./assets/21419.json")
    }
    depends_on = [helm_release.prometheus_operator]
}