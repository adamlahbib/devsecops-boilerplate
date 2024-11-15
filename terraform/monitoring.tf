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

    set {
        name  = "prometheus.prometheusSpec.additionalScrapeConfigs"
        value = <<EOT
- job_name: 'loki'
  static_configs:
    - targets: ['loki.monitoring.svc.cluster.local:3100']
EOT
    }
}

