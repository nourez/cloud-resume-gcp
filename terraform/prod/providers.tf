terraform {
  cloud {
    organization = "nourezrawji"

    workspaces {
      name = "cloud-resume-prod"
    }
  }
}

provider "google" {
  project = "cloud-resume-prod"
  region  = "northamerica-northeast2"
  zone    = "northamerica-northeast2-b"
}
