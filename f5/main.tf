resource "bigip_ltm_node" "node_1" {
  name             = "/Common/${var.server_1}"
  address          = "${var.server_1}.dimensional.com"
  fqdn {
    address_family = "ipv4"
    interval       = "3600"
  }
}
resource "bigip_ltm_node" "node_2" {
  name             = "/Common/${var.server_2}"
  address          = "${var.server_2}.dimensional.com"
  fqdn {
    address_family = "ipv4"
    interval       = "3600"
  }
}
resource "bigip_ltm_monitor" "http_monitor" {
  count       = (var.monitor_type == "http" ? 1 : 0)
  name        = "monitor_${var.web_fqdn}_http"
  parent      = "/Common/http"
  send        = "${var.monitor_string} HTTP/1.1\r\nHost: ${var.web_fqdn}\r\nUser-Agent: F5_Check\r\n\r\n"
  receive     = var.monitor_success
  receive_disable    = var.maint_flag
  username = "DFA_PRIMARY\\F5_service"
  password =  "gso5YN!itJH3bKpI=ARQ"
}
resource "bigip_ltm_monitor" "https_monitor" {
  count       = (var.monitor_type == "https" ? 1 : 0)
  name        = "/Common/monitor_${var.web_fqdn}_https"
  parent      = "/Common/https"
  send        = "${var.monitor_string} HTTP/1.1\r\nHost: ${var.web_fqdn}\r\nUser-Agent: F5_Check\r\n\r\n"
  receive     = var.monitor_success
  receive_disable    = var.maint_flag
  username = "DFA_PRIMARY\\F5_service"
  password =  "gso5YN!itJH3bKpI=ARQ"
}
resource "bigip_ltm_pool" "pool" {
  name                   = "/Common/pool_${var.web_fqdn}_${var.server_port}"
  load_balancing_mode    = "round-robin"
  minimum_active_members = 1
  monitors               = [(var.monitor_type == "http" ? "monitor_${var.web_fqdn}_http" : "monitor_${var.web_fqdn}_https")]
}
resource "bigip_ltm_pool_attachment" "attach_node" {
  pool = bigip_ltm_pool.pool.name
  node = "${bigip_ltm_node.node_1.name}:${var.client_port}"
  depends_on = [bigip_ltm_pool.pool]
}
resource "bigip_ltm_pool_attachment" "attach_node2" {
  pool = bigip_ltm_pool.pool.name
  node = "${bigip_ltm_node.node_2.name}:${var.client_port}"
  depends_on = [bigip_ltm_pool.pool]
}
resource "bigip_ltm_irule" "http_redirect" {
  count       = (var.http_redirect == "yes" ? 1 : 0)
  name  = "/Common/irule_${var.web_fqdn}_redirect_80"
  irule = <<EOF
when HTTP_REQUEST {
           switch -glob [string tolower [HTTP::host]] {
              "${var.web_fqdn}" {
                HTTP::respond 301 Location https://[getfield [HTTP::host] ":" 1][HTTP::uri]
              }
              default {
                HTTP::respond 301 Location "https://${var.web_fqdn}[HTTP::uri]"
              }
           }
        }
EOF
}
resource "bigip_ltm_irule" "https_redirect" {
  count       = (var.ssl_redirect == "yes" ? 1 : 0)
  name  = "/Common/irule_${var.web_fqdn}_redirect_443"
  irule = <<EOF
when HTTP_REQUEST {
           switch -glob [string tolower [HTTP::host]] {
              "${var.web_fqdn}" {
                # do nothing
              }
              default {
                HTTP::respond 301 Location "https://${var.web_fqdn}[HTTP::uri]"
              }
           }
        }
EOF
}
resource "bigip_ltm_virtual_server" "http_redirect" {
  count      = (var.ssl_redirect == "yes" ? 1 : 0)
  name        = "/Common/vs_${var.web_fqdn}_80"
  destination = var.vs_ip
  port        = 80
  profiles       = ["/Common/http"]
  irules      = ["/Common/irule_elk_hsl_http", "/Common/irule_${var.web_fqdn}_redirect_80"]
}
resource "bigip_ltm_virtual_server" "vs" {
  count      = (var.ssl_redirect == "yes" ? 1 : 0)
  name                       = "/Common/vs_${var.web_fqdn}_${var.client_port}"
  destination                = var.vs_ip
  port                       = var.client_port
  pool                       = "/Common/pool_${var.web_fqdn}_${var.server_port}"
  profiles                   = ["http_x-forwarded-for"]
  client_profiles            = var.ssl_policy == "offload" || var.ssl_policy == "intercept" ? ["/Common/${var.client_ssl_profile}"] : []
  server_profiles            = var.ssl_policy == "intercept" ? "[/Common/serverssl]" : []
  source_address_translation = "automap"
  persistence_profiles       = var.client_persistence == "both" ? ["cookie"] : var.client_persistence == "none" ? [] : [var.client_persistence]
  fallback_persistence_profile = var.client_persistence == "both" ? "source_addr" : ""
  irules                     = var.outage_action == "irule_auto_5xx" ? ["/Common/irule_elk_hsl_http","/Common/irule_auto_5xx"] : ["/Common/irule_elk_hsl_http","/Common/irule_auto_generic_outage"]
  depends_on                 = [bigip_ltm_pool.pool]
}
resource "bigip_ltm_virtual_server" "vs1" {
  count      = (var.ssl_redirect == "no" ? 1 : 0)
  name                       = "/Common/vs_${var.web_fqdn}_${var.client_port}"
  destination                = var.vs_ip
  port                       = var.client_port
  pool                       = "/Common/pool_${var.web_fqdn}_${var.server_port}"
  profiles                   = ["http_x-forwarded-for"]
  client_profiles            = var.ssl_policy == "offload" || var.ssl_policy == "intercept" ? ["/Common/${var.client_ssl_profile}"] : []
  server_profiles            = var.ssl_policy == "intercept" ? "[/Common/serverssl]" : []
  source_address_translation = "automap"
  persistence_profiles       = var.client_persistence == "both" ? ["cookie"] : var.client_persistence == "none" ? [] : [var.client_persistence]
  fallback_persistence_profile = var.client_persistence == "both" ? "source_addr" : ""
  irules                     = var.outage_action == "irule_auto_5xx" ? ["/Common/irule_elk_hsl_http","/Common/irule_auto_5xx"] : ["/Common/irule_elk_hsl_http","/Common/irule_auto_generic_outage"]
  depends_on                 = [bigip_ltm_pool.pool]
}
