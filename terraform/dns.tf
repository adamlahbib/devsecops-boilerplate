resource "cloudflare_record" "app" {
    zone_id = var.CLOUDFLARE_ZONE_ID
    name    = var.dns_name
    content   = try(
        data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].hostname,
        "PENDING_LB_HOSTNAME"
    )
    type    = "CNAME"
    proxied = true
    allow_overwrite = true

    lifecycle {
        ignore_changes = [
            content
        ]
    }
}