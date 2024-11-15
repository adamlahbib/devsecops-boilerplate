resource "helm_release" "grafana" {
    name       = "grafana"
    repository = "https://grafana.github.io/helm-charts"
    chart      = "grafana"
    namespace  = "monitoring"
    version    = "6.50.7"

    set {
        name  = "service.type"
        value = "NodePort"
    }

    set {
        name  = "persistence.enabled"
        value = "true"
    }
}

resource "helm_release" "loki" {
    name       = "loki"
    repository = "https://grafana.github.io/helm-charts"
    chart      = "loki-stack"
    namespace  = "monitoring"
    version    = "2.9.10"

    set {
        name  = "promtail.enabled"
        value = "true"
    }

    set {
        name  = "loki.persistence.enabled"
        value = "true"
    }
}

resource "helm_release" "prometheus" {
    name       = "prometheus"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "prometheus"
    namespace  = "monitoring"
    version    = "15.10.1"
}