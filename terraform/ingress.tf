resource "helm_release" "ingress-nginx" {
    name       = "ingress-nginx"
    repository = "https://kubernetes.github.io/ingress-nginx"
    chart      = "ingress-nginx"
    namespace  = "ingress-nginx"
    create_namespace = true
    version    = "4.11.3"

    values = [
        file("./values/ingress.yaml")
    ]
}


resource "kubernetes_ingress_v1" "dev-ingress" {
    metadata {
        name      = "dev-ingress"
        namespace = "dev"
        annotations = {
            "kubernetes.io/ingress.class" = "nginx"
            "nginx.ingress.kubernetes.io/rewrite-target" = "/"
        }
    }

    spec {
        ingress_class_name = "nginx"
        rule {
            host = "127.0.0.1"

            http {
                path {
                    path = "/dev"
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
        "kubernetes.io/ingress.class" = "nginx"
        "nginx.ingress.kubernetes.io/rewrite-target" = "/"
        }
    }

    spec {
        ingress_class_name = "nginx"
        rule {
            host = "127.0.0.1"

            http {
                path {
                    path = "/"
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
        "kubernetes.io/ingress.class" = "nginx"
        "nginx.ingress.kubernetes.io/rewrite-target" = "/"
        }
    }


    spec {
        ingress_class_name = "nginx"
        rule {
            host = "127.0.0.1"

            http {
                path {
                    path = "/grafana"
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
