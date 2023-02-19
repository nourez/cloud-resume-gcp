variable "image_tag" {
  type = string
}

module "frontend" {
  source = "../modules/frontend"
}

module "api" {
  source     = "../modules/api"
  project_id = "cloud-resume-dev"
  image_tag  = var.image_tag
}
