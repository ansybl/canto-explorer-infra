output "load_balancer_ip" {
  value = module.load_balancer[0].external_ip
}

output "nginx_reverse_proxy_url" {
  value = google_cloud_run_service.default.status.0.url
}
