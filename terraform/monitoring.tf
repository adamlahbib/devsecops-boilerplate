resource "helm_release" "grafana" {
    name       = "grafana"
    repository = "https://grafana.github.io/helm-charts"
    chart      = "grafana"
    namespace  = "monitoring"
    create_namespace = true
    version    = "6.50.7"

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
    create_namespace = true
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
    create_namespace = true
    version    = "15.10.1"
}
