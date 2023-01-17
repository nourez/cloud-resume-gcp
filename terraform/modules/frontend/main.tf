resource "random_id" "instance_id" {
  byte_length = 8
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

# Make bucket public by granting allUsers READER access
resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.static_website.id
  role   = "READER"
  entity = "allUsers"
}
