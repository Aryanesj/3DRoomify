# ----------------------------------------------------------------------------------
# Use Terraform with GCP
# Made by Artem Burmak 
# 2023
# ----------------------------------------------------------------------------------
locals {
  bucket_name = "roomify-static-site"
}
# --- | GCP Storage bucket |--------------------------------------------------------
resource "google_storage_bucket" "this" {
  name                        = local.bucket_name
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
  }
}

resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.this.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}
# --- | GitHub repository |---------------------------------------------------------
data "github_repository" "this" {
  full_name = "${var.github_owner}/${var.github_repository}"
}
# --- | Download app to Storage bucket |--------------------------------------------
resource "null_resource" "upload_files" {
  provisioner "local-exec" {
    command = <<-EOT
      rm -rf repo
      git clone https://${var.github_token}@github.com/${data.github_repository.this.full_name} repo
      cd repo
      npm install
      npm run build
      gsutil -m rsync -d -r build/ gs://${google_storage_bucket.this.name}
      cd ..
      rm -rf repo
    EOT
  }

  depends_on = [google_storage_bucket.this]
}
# --- | Create Global IP Address |--------------------------------------------------
resource "google_compute_global_address" "load_balancer_ip" {
  name         = "load-balancer-ip"
  project      = var.project
  address_type = "EXTERNAL"

  lifecycle {
    create_before_destroy = true
  }
}

# --- | Create Backend Bucket for GCS Bucket |--------------------------------------
resource "google_compute_backend_bucket" "backend_bucket" {
  name        = "${local.bucket_name}-backend"
  bucket_name = local.bucket_name
  enable_cdn  = true
}

# --- | Create URL Map |------------------------------------------------------------
resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_bucket.backend_bucket.self_link
}
# --- | Create HTTP Target Proxy |--------------------------------------------------
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.url_map.self_link
}
# --- | Create Global Forwarding Rule |---------------------------------------------
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "forwarding-rule"
  project    = var.project
  target     = google_compute_target_http_proxy.http_proxy.self_link
  ip_address = google_compute_global_address.load_balancer_ip.address
  port_range = "80"
}

# --- | Create Firewall Rule to allow Health Checks |-------------------------------
resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}
# ---| A-record in CloudFlare |-----------------------------------------------------
data "cloudflare_zones" "roomify" {
  filter {
    name   = "3droomify.com"
    status = "active"
    paused = false
  }
}

resource "cloudflare_record" "this" {
  zone_id = data.cloudflare_zones.roomify.zones[0].id
  name    = "3droomify.com"
  value   = google_compute_global_address.load_balancer_ip.address
  type    = "A"
  ttl     = 1
  proxied = true
}
# --- | Create Target HTTPS Proxy |-------------------------------------------------
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.ssl_cert.self_link]
}

# --- | Update Global Forwarding Rule for HTTPS |-----------------------------------
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name       = "https-forwarding-rule"
  project    = var.project
  target     = google_compute_target_https_proxy.https_proxy.self_link
  ip_address = google_compute_global_address.load_balancer_ip.address
  port_range = "443"
}
# --- | Request Managed SSL Certificate in GCP |-------------------------------------
resource "google_compute_managed_ssl_certificate" "ssl_cert" {
  name = "ssl-certificate"
  managed {
    domains = ["3droomify.com"]
  }
}
