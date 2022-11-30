resource "google_compute_global_address" "load_balancer_address" {
  name       = "${local.service_name}-load-balancer-address-${local.environment}"
  ip_version = "IPV4"
}
