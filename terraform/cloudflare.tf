terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = data.google_secret_manager_secret_version.cloudflare_api_token.secret_data
}

resource "cloudflare_record" "this" {
  count   = var.create_cloudflare ? 1 : 0
  name    = var.domain_prefix
  zone_id = var.cloudflare_zone_id
  value   = "ghs.googlehosted.com"
  type    = "CNAME"
  proxied = true
}
