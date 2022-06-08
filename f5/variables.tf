variable "environment" {
  type    = string
}
variable "location" {
  type    = string
}
variable "datacenter" {
  type    = string
}
variable "web_fqdn" {
  type    = string
}
variable "client_port" {
  type    = string
}
variable "client_persistence" {
  type    = string
}
variable "ssl" {
  type    = string
}
variable "ssl_policy" {
  type    = string
}
variable "http_redirect" {
  type    = string
}
variable "ssl_redirect" {
  type    = string
}
variable "server_1" {
  type    = string
}
variable "server_2" {
  type    = string
}
variable "server_port" {
  type    = string
}
variable "monitor_string" {
  type    = string
}
variable "monitor_success" {
  type    = string
}
variable "monitor_auth" {
  type    = string
}
variable "maint_flag" {
  type    = string
}
variable "outage_action" {
  type    = string
}
variable "client_ssl_profile" {
  type    = string
}
variable "route_domain" {
  type    = string
}
variable "vs_ip" {
  type    = string
}
variable "monitor_type" {
  type    = string
}
variable "client" {
  type    = list(string)
}
variable "sever_pro" {
  type    = list(string)
}
variable "irule" {
  type    = list(string)
}
