resource "helm_release" "nginx-ingress-controller" {
    name       = "nginx-ingress-controller"
    repository = "https://charts.bitnami.com/bitnami"
    chart      = "nginx-ingress-controller"

    set {
        name  = "service.type"
        value = "LoadBalancer"
    }

    set {
        name  = "controller.publishService.enabled"
        value = "true"
    }
    set {
        name  = "controller.defaultTLS.secret"
        value = "default/tls-cert"
    }
}

data "kubernetes_service" "nginx_ingress" {
    metadata {
    name      = "nginx-ingress-controller"
    namespace = "default"
    }
}

resource "kubernetes_namespace" "dev" {
    metadata {
        name = "dev"
    }
}

resource "kubernetes_namespace" "prod" {
    metadata {
        name = "prod"
    }
}

resource "kubernetes_ingress_v1" "dev-ingress" {
    metadata {
        name      = "dev-ingress"
        namespace = "dev"
        annotations = {
            "nginx.ingress.kubernetes.io/ssl-redirect"    = "false"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "false"
            "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
        }
    }


    spec {
        ingress_class_name = "nginx"

        tls {
            hosts      = ["${var.dns_name}"]
            secret_name = "tls-cert"
        }

        rule {
            host = var.dns_name

            http {
                path {
                    path = "/dev/"
                    path_type = "Prefix"
                    backend{
                        service {
                            name = "app-service"
                            port {
                                number = 8080
                            }
                        }
                    }
                }
            }
        }
    }
    depends_on = [helm_release.nginx-ingress-controller, kubernetes_namespace.dev]
}

resource "kubernetes_ingress_v1" "prod-ingress" {
    metadata {
        name      = "prod-ingress"
        namespace = "prod"
        annotations = {
            "nginx.ingress.kubernetes.io/ssl-redirect"    = "false"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "false"
            "nginx.ingress.kubernetes.io/backend-protocol" = "HTTP"
        }
    }
    

    spec {
        ingress_class_name = "nginx"

        tls {
            hosts      = ["${var.dns_name}"]
            secret_name = "tls-cert"
        }

        rule {
            host = var.dns_name

            http {
                path {
                    path = "/"
                    path_type = "Prefix"
                    backend{
                        service {
                            name = "app-service"
                            port {
                                number = 80
                            }
                        }
                    }
                }
            }
        }
    }
    depends_on = [helm_release.nginx-ingress-controller, kubernetes_namespace.prod]
}

resource "kubernetes_ingress_v1" "monitoring-ingress" {
    metadata {
        name      = "monitoring-ingress"
        namespace = "monitoring"
        annotations = {
            "tailscale.com/tags" = "tag:aqemia-monitoring"
        }
    }


    spec {
        ingress_class_name = "tailscale"

        tls {
            hosts      = ["${var.project_name}"]
        }

        rule {
            host = var.project_name

            http {
                path {
                    path = "/grafana/"
                    path_type = "Prefix"
                    backend{
                        service {
                            name = "prometheus-operator-grafana"
                            port {
                                number = 80
                            }
                        }
                    }
                }
                path {
                    path = "/falco/"
                    path_type = "Prefix"
                    backend{
                        service {
                            name = "falco-falcosidekick-ui"
                            port {
                                number = 2802
                            }
                        }
                    }
                }
            }
        }
    }
    depends_on = [helm_release.tailscale_operator, helm_release.prometheus_operator, helm_release.falco]
}
