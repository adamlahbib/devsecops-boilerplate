resource "kubernetes_namespace" "monitoring" {
    metadata {
        name = "monitoring"
    }
    depends_on = [aws_eks_node_group.eks_nodes]
}

resource "kubernetes_config_map" "grafana_datasources" {
    metadata {
        name     = "grafana-datasources"
        namespace = "monitoring"
        labels = {
            grafana_datasource = "1"
        }
    }
    data = {
        "ds.yaml" = yamlencode({
            apiVersion = 1
            datasources = [
                {
                    name = "Prometheus"
                    type = "prometheus"
                    access = "proxy"
                    url = "http://prometheus-operated:9090"
                    isDefault = true
                    uid: "dsprometheusuid"
                },
                {
                    name = "Alertmanager"
                    type = "prometheus"
                    access = "proxy"
                    url = "http://prometheus-operator-kube-p-alertmanager:9093"
                },
                {
                    name = "Loki"
                    type = "loki"
                    access = "proxy"
                    url = "http://loki:3100"
                },
                {
                    name = "Tempo"
                    type = "tempo"
                    access = "proxy"
                    url = "http://tempo:3100"
                }
            ]
        })
    }
    depends_on = [aws_eks_node_group.eks_nodes, kubernetes_namespace.monitoring]
}

resource "helm_release" "prometheus_operator" {
    name       = "prometheus-operator"
    repository = "https://prometheus-community.github.io/helm-charts"
    chart      = "kube-prometheus-stack"
    namespace  = "monitoring"
    create_namespace = true
    version    = "66.2.1"

    values = [
        file("./assets/alertmanager-config.yaml"),
        yamlencode({
        grafana= {
            enabled = true
            service = {
                type = "ClusterIP"
            }
            "grafana.ini" = {
                server = {
                    root_url = "https://grafana.${var.tailnet}/"
                    domain = "grafana.${var.tailnet}"
                    serve_from_sub_path = true
                    cookie_samesite = "none"
                    cookie_secure = true
                }
            }
            adminPassword = var.GRAFANA_ADMIN_PASSWORD
        }
        alertmanager = {
            enabled = true
            config = yamlencode({
                global = {
                    resolve_timeout = "5m"
                }
                route = {
                    group_by = ["alertname"]
                    group_wait = "30s"
                    group_interval = "5m"
                    repeat_interval = "3h"
                    receiver = "slack"
                }
                receivers = [
                    {
                        name = "slack"
                        slack_configs = [
                            {
                                api_url = var.SLACK_WEBHOOK
                                channel = var.slack_alerts_channel
                                send_resolved = true
                            }
                        ]
                    }
                ]
            })
        }

        prometheus = {
            prometheusSpec = {
                additionalScrapeConfigs = [
                    {
                        job_name = "crowdsec"
                        scrape_interval = "60s"
                        metrics_path = "/metrics"
                        static_configs = [
                            {
                                targets = ["crowdsec-service.crowdsec.svc.cluster.local:6060"]
                            }
                        ]
                    }
                ]
            }
        }
    })]

    depends_on = [kubernetes_config_map.grafana_datasources]
}

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
    depends_on = [helm_release.prometheus_operator]
}

resource "helm_release" "tempo" {
    name      = "tempo"
    repository = "https://grafana.github.io/helm-charts"
    chart     = "tempo"
    namespace = "monitoring"
    create_namespace = true
    version   = "1.14.0"
    depends_on = [helm_release.prometheus_operator]
}

resource "kubernetes_config_map" "grafana_dashboards" {
    metadata {
        name     = "grafana-dashboards"
        namespace = "monitoring"
        labels = {
            grafana_dashboard = "1"
        }
    }
    data = {
        "21419.json" = file("./assets/21419.json"),
        "crowdsec_v5.json" = file("./assets/crowdsec_v5.json")
    }
    depends_on = [aws_eks_node_group.eks_nodes, helm_release.prometheus_operator]
}
