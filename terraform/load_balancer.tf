resource "google_compute_region_network_endpoint_group" "this" {
  count                 = var.create_load_balancer ? 1 : 0
  project               = var.project
  name                  = "${local.service_name}-neg-${local.environment}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.default.name
  }
}

module "load_balancer" {
  count          = var.create_load_balancer ? 1 : 0
  source         = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version        = "6.3.0"
  project        = var.project
  name           = "${local.service_name}-load-balancer-${local.environment}"
  create_address = false
  address        = google_compute_global_address.load_balancer_address.address

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.this[0].id
        }
      ]
      enable_cdn              = false
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }

      log_config = {
        enable      = true
        sample_rate = 0.01
      }
    }
  }
}
