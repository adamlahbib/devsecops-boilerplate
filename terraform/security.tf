resource "helm_release" "falco" {
    name       = "falco"
    repository = "https://falcosecurity.github.io/charts"
    chart      = "falco"
    namespace  = "falco"
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

    set {
        name = "falcosidekick.webui.redis.storageEnabled"
        value = "false"
    }
    depends_on = [aws_eks_node_group.eks_nodes]
}

resource "kubernetes_namespace" "crowdsec" {
    metadata {
        name = "crowdsec"
    }
    depends_on = [aws_eks_node_group.eks_nodes]
}

resource "random_password" "crowdsec_bouncer_key_value" {
    length           = 32
    special          = true
    override_special = "!@#$%&*()-_=+[]{}<>:?"
}

resource "kubernetes_secret" "crowdsec_bouncer_key" {
    metadata {
        name      = "crowdsec-bouncer-key"
        namespace = "crowdsec"
    }
    data = {
        BOUNCER_KEY_nginx = random_password.crowdsec_bouncer_key_value.result
    }
    depends_on = [random_password.crowdsec_bouncer_key_value, kubernetes_namespace.crowdsec]
}

resource "kubernetes_secret" "crowdsec-enroll-key" {
    metadata {
        name      = "crowdsec-enroll-key"
        namespace = "crowdsec"
    }
    data = {
        ENROLL_KEY = var.CROWDSEC_ENROLL_KEY
    }
    depends_on = [kubernetes_namespace.crowdsec]
}

resource "helm_release" "crowdsec" {
    name       = "crowdsec"
    repository = "https://crowdsecurity.github.io/helm-charts"
    chart      = "crowdsec"
    namespace  = "crowdsec"
    create_namespace = true
    version    = "0.13.0"

    values = [
        file("./assets/crowdsec-values.yaml")
    ]

    depends_on = [kubernetes_secret.crowdsec_bouncer_key, kubernetes_namespace.crowdsec, kubernetes_secret.crowdsec-enroll-key]
}