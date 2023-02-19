variable "project_id" {
  description = "Google Cloud Project Id where the resources will be created"
  type        = string
  default     = "cloud-resume-dev"
}

variable "image_tag" {
  description = "The tag of the image to deploy"
  type        = string
}
