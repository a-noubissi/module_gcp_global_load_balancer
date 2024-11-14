
data "google_cloud_run_service" "service" {
  provider = google.cloudrun
  name     = var.cloudrun_name
  location = var.cloudrun_location
}

locals {
  cloudrun_trimmed_name = trimsuffix(var.cloudrun_name,"-${terraform.workspace}" )
}

resource "google_compute_global_forwarding_rule" "fwd_rule" {
  provider              = google.project
  name                  = "${local.cloudrun_trimmed_name}-${terraform.workspace}-forwarding-rule"
  target                = google_compute_target_https_proxy.default.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = var.ip_address
  ip_protocol           = "TCP"
  port_range            = "443-443"
}


resource "google_compute_url_map" "urlmap" {
  provider = google.project
  name     = "${local.cloudrun_trimmed_name}-${terraform.workspace}-glb-url-map"
  default_service = google_compute_backend_service.service.id
}

resource "google_compute_target_https_proxy" "default" {
  provider         = google.project
  name             = "${local.cloudrun_trimmed_name}-${terraform.workspace}-proxy"
  url_map          = google_compute_url_map.urlmap.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default.id]
}

resource "google_compute_managed_ssl_certificate" "default" {
  provider = google.project
  name     = "${local.cloudrun_trimmed_name}-${terraform.workspace}-glb-cert"
  managed {
    domains = [var.domain]
  }
}

resource "google_compute_region_network_endpoint_group" "neg" {
  provider = google.project
  name     = "${local.cloudrun_trimmed_name}-${terraform.workspace}-neg"
  region   = "europe-west4"
  cloud_run {
    service = data.google_cloud_run_service.service.name
  }
}

resource "google_compute_backend_service" "service" {
  provider = google.project
  name                  = "${local.cloudrun_trimmed_name}-${terraform.workspace}-glb-service"
  protocol              = "HTTPS"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  backend {
    group = google_compute_region_network_endpoint_group.neg.id
  }
}
