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

