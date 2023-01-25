variable "cert_domains" {
  description = "Domains for the certificate"
  type        = list(string)
  default     = ["nourez.dev", "www.nourez.dev"]
}
