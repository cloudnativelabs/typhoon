# Static IP for the Network Load Balancer
resource "google_compute_address" "ingress-ip" {
  name = "${var.cluster_name}-ingress-ip"
}

# Network Load Balancer (i.e. forwarding rules)
resource "google_compute_forwarding_rule" "worker-http-lb" {
  name       = "${var.cluster_name}-worker-http-rule"
  ip_address = "${google_compute_address.ingress-ip.address}"
  port_range = "80"
  target     = "${google_compute_target_pool.workers.self_link}"
}

resource "google_compute_forwarding_rule" "worker-https-lb" {
  name       = "${var.cluster_name}-worker-https-rule"
  ip_address = "${google_compute_address.ingress-ip.address}"
  port_range = "443"
  target     = "${google_compute_target_pool.workers.self_link}"
}

# Network Load Balancer target pool of instances.
resource "google_compute_target_pool" "workers" {
  name = "${var.cluster_name}-worker-pool"

  health_checks = [
    "${google_compute_http_health_check.ingress.name}",
  ]

  session_affinity = "NONE"
}

# Ingress HTTP Health Check
resource "google_compute_http_health_check" "ingress" {
  name        = "${var.cluster_name}-ingress-health"
  description = "Health check Ingress controller health host port"

  timeout_sec        = 5
  check_interval_sec = 5

  healthy_threshold   = 2
  unhealthy_threshold = 4

  port         = 10254
  request_path = "/healthz"
}
