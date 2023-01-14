terraform {
  cloud {
    organization = "nourezrawji"

    workspaces {
      name = "cloud-resume-dev"
    }
  }
}

provider "google" {
  project = "cloud-resume-dev"
  region  = "northamerica-northeast2"
  zone    = "northamerica-northeast2-b"
}

resource "random_id" "instance_id" {
  byte_length = 8
}

# Create a bucket to store the static website 
resource "google_storage_bucket" "static_website" {
  name                        = "terraform-test-${random_id.instance_id.hex}"
  location                    = "NORTHAMERICA-NORTHEAST2"
  storage_class               = "STANDARD"
  force_destroy               = true
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "error.html"
  }
}
