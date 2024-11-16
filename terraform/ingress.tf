# resource "helm_release" "ingress-nginx" {
#     name       = "ingress-nginx"
#     repository = "https://kubernetes.github.io/ingress-nginx"
#     chart      = "ingress-nginx"
#     namespace  = "ingress-nginx"
#     create_namespace = true
#     version    = "4.11.3"

#     values = [
#         file("./values/ingress.yaml")
#     ]
# }

# resource "kubernetes_ingress" "dev-ingress" {
#     metadata {
#         name      = "dev-ingress"
#         namespace = "dev"
#         annotations = {
#         "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#         }
#     }

#     spec {
#         rule {
#             host = "test.local"

#             http {
#                 path {
#                     path = "/dev"
#                     backend {
#                         service_name = "app-service"
#                         service_port = 8080
#                     }
#                 }
#             }
#         }
#     }
# }

# resource "kubernetes_ingress" "prod-ingress" {
#     metadata {
#         name      = "prod-ingress"
#         namespace = "prod"
#         annotations = {
#         "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#         }
#     }

#     spec {
#         rule {
#             host = "test.local"

#             http {
#                 path {
#                     path = "/"
#                     backend {
#                         service_name = "app-service"
#                         service_port = 80
#                     }
#                 }
#             }
#         }
#     }
# }

# resource "kubernetes_ingress" "monitoring-ingress" {
#     metadata {
#         name      = "monitoring-ingress"
#         namespace = "monitoring"
#         annotations = {
#         "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#         }
#     }

#     spec {
#         rule {
#             host = "test.local"

#             http {
#                 path {
#                     path = "/grafana"
#                     backend {
#                         service_name = "grafana"
#                         service_port = 3000
#                     }
#                 }
#                 path {
#                     path = "/loki"
#                     backend {
#                         service_name = "loki"
#                         service_port = 3100
#                     }
#                 }
#             }
#         }
#     }
# }

# resource "kubernetes_ingress" "falco-ingress" {
#     metadata {
#         name      = "falco-ingress"
#         namespace = "falco"
#         annotations = {
#         "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#         }
#     }

#     spec {
#         rule {
#             host = "test.local"

#             http {
#                 path {
#                     path = "/falco"
#                     backend {
#                         service_name = "falcosidekick-ui"
#                         service_port = 2801
#                     }
#                 }
#             }
#         }
#     }
# }