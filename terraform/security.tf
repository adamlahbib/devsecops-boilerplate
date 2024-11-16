resource "helm_release" "falco" {
    name       = "falco"
    repository = "https://falcosecurity.github.io/charts"
    chart      = "falco"
    namespace  = "monitoring"
    create_namespace = true
    version    = "4.14.1"

    set {
        name  = "ebpf.enabled"
        value = "true"
    }
}

resource "helm_release" "falco_sidekick" {
    name       = "falcosidekick"
    repository = "https://falcosecurity.github.io/charts"
    chart      = "falcosidekick"
    namespace  = "monitoring"
    create_namespace = true
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
    namespace  = "crowdsec"
    create_namespace = true
    version    = "0.13.0"

    values = [
        file("./values/crowdsec.yaml")
    ]
}