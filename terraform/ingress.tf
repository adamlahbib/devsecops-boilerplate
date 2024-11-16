resource "helm_release" "nginx-ingress-controller" {
    name       = "nginx-ingress-controller"
    repository = "https://charts.bitnami.com/bitnami"
    chart      = "nginx-ingress-controller"

    set {
        name  = "service.type"
        value = "LoadBalancer"
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
            "nginx.ingress.kubernetes.io/rewrite-target" = "/"
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
        }
    }


    spec {
        ingress_class_name = "nginx"
        rule {
            host = "aqemia.admida0ui.de"

            http {
                path {
                    path = "/dev"
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
}

resource "kubernetes_ingress_v1" "prod-ingress" {
    metadata {
        name      = "prod-ingress"
        namespace = "prod"
        annotations = {
            "nginx.ingress.kubernetes.io/rewrite-target" = "/"
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
        }
    }
    

    spec {
        ingress_class_name = "nginx"
        rule {
            host = "aqemia.admida0ui.de"

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
}

resource "kubernetes_ingress_v1" "monitoring-ingress" {
    metadata {
        name      = "monitoring-ingress"
        namespace = "monitoring"
        annotations = {
            "nginx.ingress.kubernetes.io/rewrite-target" = "/"
            "nginx.ingress.kubernetes.io/ssl-redirect" = "true"
        }
    }


    spec {
        ingress_class_name = "nginx"
        rule {
            host = "aqemia.admida0ui.de"

            http {
                path {
                    path = "/grafana"
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
                    path = "/falco"
                    path_type = "Prefix"
                    backend{
                        service {
                            name = "falcosidekick"
                            port {
                                number = 2801
                            }
                        }
                    }
                }
            }
        }
    }
}
