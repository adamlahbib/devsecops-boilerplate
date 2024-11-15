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

resource "helm_release" "falco" {
    name       = "falco"
    repository = "https://falcosecurity.github.io/charts"
    chart      = "falco"
    namespace  = "monitoring"
    version    = "4.14.1"

    set {
        name  = "ebpf.enabled"
        value = "true"
    }
}

resource "helm_release" "falco_sidekick" {
    name       = "falco-sidekick"
    repository = "https://falcosecurity.github.io/charts"
    chart      = "falco-sidekick"
    namespace  = "monitoring"
    version    = "0.8.9"

    set {
        name  = "falcosidekick.enabled"
        value = "true"
    }

    set {
        name  = "falco.webui.enabled"
        value = "true"
    }

    set {
        name  = "falco.webui.service.type"
        value = "NodePort"
    }
}

resource "helm_release" "crowdsec" {
    name       = "crowdsec"
    repository = "https://crowdsecurity.github.io/helm-charts"
    chart      = "crowdsec"
    namespace  = "monitoring"
    version    = "0.13.0"
}