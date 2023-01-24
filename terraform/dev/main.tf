module "frontend" {
  source       = "../modules/frontend"
  cert_domains = ["dev.nourez.dev"]
}
