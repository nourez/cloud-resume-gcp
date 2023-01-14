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
