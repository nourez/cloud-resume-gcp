resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_storage_bucket_iam_binding" "public_access_policy" {
  bucket = google_storage_bucket.static_website.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}

# Create a bucket to store the static website 
resource "google_storage_bucket" "static_website" {
  name                        = "cloud-resume-${random_id.instance_id.hex}"
  location                    = "US"
  storage_class               = "STANDARD"
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "error.html"
  }
}

resource "google_storage_bucket_object" "index_html" {
  name         = "index.html"
  bucket       = google_storage_bucket.static_website.name
  source       = "../../frontend/index.html"
  content_type = "text/html"
}

resource "google_storage_bucket_object" "error_html" {
  name         = "error.html"
  bucket       = google_storage_bucket.static_website.name
  source       = "../../frontend/error.html"
  content_type = "text/html"
}

resource "google_storage_bucket_object" "styles_css" {
  name         = "styles.css"
  bucket       = google_storage_bucket.static_website.name
  source       = "../../frontend/styles.css"
  content_type = "text/css"
}

resource "google_storage_bucket_object" "index_js" {
  name         = "index.js"
  bucket       = google_storage_bucket.static_website.name
  source       = "../../frontend/index.js"
  content_type = "text/javascript"
}

resource "google_storage_bucket_object" "nourez_jpg" {
  name         = "nourez.jpg"
  bucket       = google_storage_bucket.static_website.name
  source       = "../../frontend/nourez.jpg"
  content_type = "image/jpeg"
}

# Reserve a static IP address for the frontend
resource "google_compute_global_address" "resume_ip" {
  name = "cloud-resume-ip"
}

# Create a bucket backend service to serve the static website
resource "google_compute_backend_bucket" "resume_backend" {
  name        = "cloud-resume-backend"
  bucket_name = google_storage_bucket.static_website.name
  description = "Backend bucket for the cloud resume website"
  enable_cdn  = true
}

# Create a HTTPS certificate for the frontend {
resource "google_compute_managed_ssl_certificate" "resume_cert" {
  name        = "cloud-resume-cert"
  description = "Certificate for the cloud resume website"
  managed {
    domains = var.cert_domains
  }
}

# Route all requests to the backend bucket
resource "google_compute_url_map" "resume_url_map" {
  name            = "cloud-resume-lb"
  default_service = google_compute_backend_bucket.resume_backend.self_link
}

# Create a load balancer to serve the static website
resource "google_compute_target_https_proxy" "resume_target_proxy" {
  name    = "cloud-resume-lb-target-proxy"
  url_map = google_compute_url_map.resume_url_map.self_link
  ssl_certificates = [
    google_compute_managed_ssl_certificate.resume_cert.self_link,
  ]
}

# Add a frontend to the load balancer
resource "google_compute_global_forwarding_rule" "resume_forwarding_rule" {
  name       = "cloud-resume-lb-forwarding-rule"
  target     = google_compute_target_https_proxy.resume_target_proxy.self_link
  ip_address = google_compute_global_address.resume_ip.address
  port_range = "443"
}

# Redirect HTTP requests to HTTPS
resource "google_compute_url_map" "resume_redirect_map" {
  name = "cloud-resume-lb-http-redirect"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
    https_redirect         = true
  }
}

resource "google_compute_target_http_proxy" "resume_redirect_proxy" {
  name    = "cloud-resume-lb-redirect-proxy"
  url_map = google_compute_url_map.resume_redirect_map.self_link
}

resource "google_compute_global_forwarding_rule" "resume_redirect_rule" {
  name       = "cloud-resume-lb-redirect-rule"
  target     = google_compute_target_http_proxy.resume_redirect_proxy.self_link
  ip_address = google_compute_global_address.resume_ip.address
  port_range = "80"
}

# Update DNS records with load balancers
data "google_dns_managed_zone" "cloud_resume_zone" {
  name    = "nourez-dev"
  project = "cloud-resume-shared-services"
}

resource "google_dns_record_set" "cloud_resume" {
  name         = "${var.cert_domains[0]}."
  type         = "A"
  ttl          = 300
  managed_zone = data.google_dns_managed_zone.cloud_resume_zone.name
  project      = data.google_dns_managed_zone.cloud_resume_zone.project

  rrdatas = [
    google_compute_global_address.resume_ip.address,
  ]
}


