resource "helm_release" "prometheus_operator" {
    name       = "prometheus-operator"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "kube-prometheus-stack"
    namespace  = "monitoring"
    create_namespace = true
    version    = "66.2.1"

    set {
        name  = "grafana.enabled"
        value = "true"
    }

    set {
        name  = "grafana.adminPassword"
        value = var.GRAFANA_ADMIN_PASSWORD
    }

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

