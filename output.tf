output "ip_adress" {
  value = google_compute_global_address.ip_address.address
}

output "domain" {
  value = google_compute_managed_ssl_certificate.default.managed
}