module "frontend" {
  source       = "../modules/frontend"
  cert_domains = ["uat.nourez.dev"]
}
