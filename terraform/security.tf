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
    set {
        name  = "falcosidekick.enabled"
        value = "true"
    }

    set {
        name  = "falcosidekick.webui.enabled"
        value = "true"
    }

    set {
        name  = "falcosidekick.config.slack.webhookurl"
        value = var.SLACK_WEBHOOK
    }

    set {
        name = "falcosidekick.config.slack.channel"
        value = var.slack_channel
    }

    set {
        name = "falcosidekick.config.slack.username"
        value = var.slack_username
    }

    set {
        name = "falcosidekick.config.slack.icon"
        value = var.slack_icon
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