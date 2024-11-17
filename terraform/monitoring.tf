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
                    root_url = "https://${var.dns_name}/grafana/"
                    domain = var.dns_name
                    serve_from_sub_path = true
                }
            }
            adminPassword = var.GRAFANA_ADMIN_PASSWORD
        }
    })]

    env = [
        {
            name = "GF_SERVER_ROOT_URL"
            value = "https://${var.dns_name}/grafana/"
        },
        {
            name = "GF_SERVER_SERVE_FROM_SUB_PATH"
            value = "true"
        },
        {
            name  = "GF_SECURITY_COOKIE_SAMESITE"
            value = "none"
        },
        {
            name  = "GF_SECURITY_COOKIE_SECURE"
            value = "true"
        }
    ]

    set {
        name  = "prometheus.prometheusSpec.retention"
        value = "15d"
    }

    set {
        name  = "prometheus.prometheusSpec.persistence.enabled"
        value = "false"
    }

    set {
        name  = "alertmanager.enabled"
        value = "true"
    }
}

