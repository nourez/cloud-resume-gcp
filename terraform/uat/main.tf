variable "image_tag" {
  type = string
}

module "frontend" {
  source       = "../modules/frontend"
  cert_domains = ["uat.nourez.dev"]
}

module "api" {
  source     = "../modules/api"
  project_id = "cloud-resume-uat"
  image_tag  = var.image_tag
}
