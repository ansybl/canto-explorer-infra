resource "google_compute_global_address" "load_balancer_address" {
  provider   = google-beta
  name       = "${local.service_name}-load-balancer-address-${local.environment}"
  ip_version = "IPV4"

  labels = {
    environment  = local.environment
    service_name = local.service_name
    prefix       = var.prefix
  }
}
