output "load_balancer_ip" {
  value = var.create_load_balancer ? module.load_balancer[0].external_ip : null
}

output "nginx_reverse_proxy_url" {
  value = google_cloud_run_service.default.status.0.url
}
