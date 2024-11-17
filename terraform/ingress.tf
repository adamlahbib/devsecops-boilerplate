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
            "nginx.ingress.kubernetes.io/rewrite-target" = "/"
            "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/secure-backends"                 = "true"
            "nginx.ingress.kubernetes.io/proxy-body-size"                 = "10m"
            "nginx.ingress.kubernetes.io/ssl-protocols"                   = "TLSv1.2 TLSv1.3"
            "nginx.ingress.kubernetes.io/ssl-ciphers"                     = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384"
            "nginx.ingress.kubernetes.io/proxy-read-timeout"              = "30"
            "nginx.ingress.kubernetes.io/proxy-send-timeout"              = "30"
            "nginx.ingress.kubernetes.io/hsts"                            = "true"
            "nginx.ingress.kubernetes.io/hsts-max-age"                    = "63072000"
            "nginx.ingress.kubernetes.io/hsts-include-subdomains"         = "true"
            "nginx.ingress.kubernetes.io/hsts-preload"                    = "true"        
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
                    path = "/dev(/|$)(.*)"
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
            "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/secure-backends"                 = "true"
            "nginx.ingress.kubernetes.io/proxy-body-size"                 = "10m"
            "nginx.ingress.kubernetes.io/ssl-protocols"                   = "TLSv1.2 TLSv1.3"
            "nginx.ingress.kubernetes.io/ssl-ciphers"                     = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384"
            "nginx.ingress.kubernetes.io/proxy-read-timeout"              = "30"
            "nginx.ingress.kubernetes.io/proxy-send-timeout"              = "30"
            "nginx.ingress.kubernetes.io/hsts"                            = "true"
            "nginx.ingress.kubernetes.io/hsts-max-age"                    = "63072000"
            "nginx.ingress.kubernetes.io/hsts-include-subdomains"         = "true"
            "nginx.ingress.kubernetes.io/hsts-preload"                    = "true"        
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
}

resource "kubernetes_ingress_v1" "monitoring-ingress" {
    metadata {
        name      = "monitoring-ingress"
        namespace = "monitoring"
        annotations = {
            "nginx.ingress.kubernetes.io/rewrite-target" = "/"
            "nginx.ingress.kubernetes.io/ssl-redirect"    = "true"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
            "nginx.ingress.kubernetes.io/secure-backends"                 = "true"
            "nginx.ingress.kubernetes.io/proxy-body-size"                 = "10m"
            "nginx.ingress.kubernetes.io/ssl-protocols"                   = "TLSv1.2 TLSv1.3"
            "nginx.ingress.kubernetes.io/ssl-ciphers"                     = "ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384"
            "nginx.ingress.kubernetes.io/proxy-read-timeout"              = "30"
            "nginx.ingress.kubernetes.io/proxy-send-timeout"              = "30"
            "nginx.ingress.kubernetes.io/hsts"                            = "true"
            "nginx.ingress.kubernetes.io/hsts-max-age"                    = "63072000"
            "nginx.ingress.kubernetes.io/hsts-include-subdomains"         = "true"
            "nginx.ingress.kubernetes.io/hsts-preload"                    = "true"
            "nginx.ingress.kubernetes.io/proxy-set-headers" = "configmap/custom-headers"
            "nginx.ingress.kubernetes.io/proxy-buffer-size" = "16k"
            "nginx.ingress.kubernetes.io/configuration-snippet" = "proxy_set_header X-Forwarded-Host $host; proxy_set_header X-Forwarded-Proto $scheme; proxy_set_header X-Forwarded-Uri $request_uri;"
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
                    path = "/grafana(/|$)(.*)"
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
                    path = "/falco(/|$)(.*)"
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
