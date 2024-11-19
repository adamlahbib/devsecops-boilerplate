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

    values = [
        file("./assets/crowdsec-ingress-nginx.yaml")
    ]

    depends_on = [helm_release.crowdsec]

}

data "kubernetes_service" "nginx_ingress" {
    metadata {
        name      = "nginx-ingress-controller"
        namespace = "default"
    }
    depends_on = [helm_release.nginx-ingress-controller]
}

resource "kubernetes_namespace" "dev" {
    metadata {
        name = "dev"
    }
    depends_on = [helm_release.nginx-ingress-controller]
}

resource "kubernetes_namespace" "prod" {
    metadata {
        name = "prod"
    }
    depends_on = [helm_release.nginx-ingress-controller]
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

resource "kubernetes_ingress_v1" "falco-ingress" {
    metadata {
        name      = "falco-ingress"
        namespace = "falco"
    }

    spec {
        ingress_class_name = "tailscale"

        tls {
            hosts      = ["falco"]
        }

        rule {
            host = "falco"

            http {
                path {
                    path = "/"
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
    depends_on = [helm_release.tailscale_operator, helm_release.falco]
}

resource "kubernetes_ingress_v1" "monitoring-ingress" {
    metadata {
        name      = "monitoring-ingress"
        namespace = "monitoring"
    }

    spec {
        ingress_class_name = "tailscale"

        tls {
            hosts      = ["monitoring"]
        }

        rule {
            host = "monitoring"

            http {
                path {
                    path = "/"
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
            }
        }
    }
    depends_on = [helm_release.tailscale_operator, helm_release.prometheus_operator]
}

