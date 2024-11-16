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

    set {
        name  = "grafana.enabled"
        value = "true"
    }

    set {
        name = "grafana.service.type"
        value = "ClusterIP"
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

