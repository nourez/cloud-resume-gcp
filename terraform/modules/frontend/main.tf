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
  name            = "cloud-resume-url-map"
  default_service = google_compute_backend_bucket.resume_backend.self_link
}
