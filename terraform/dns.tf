resource "cloudflare_record" "app" {
    zone_id = var.CLOUDFLARE_ZONE_ID
    name    = var.dns_name
    value   = try(
        kubernetes_ingress_v1.prod-ingress.status[0].load_balancer[0].ingress[0].hostname,
        "PENDING_LB_HOSTNAME"
    )
    type    = "CNAME"
    proxied = true
    allow_overwrite = true

    lifecycle {
        ignore_changes = [
            value
        ]
    }
}