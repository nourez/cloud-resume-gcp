terraform {
  cloud {
    organization = "nourezrawji"

    workspaces {
      name = "cloud-resume-uat"
    }
  }
}

provider "google" {
  project = "cloud-resume-uat"
  region  = "northamerica-northeast2"
  zone    = "northamerica-northeast2-b"
}
