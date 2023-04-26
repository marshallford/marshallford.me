variable "repository" {
  type     = string
  nullable = false
}

variable "google_region" {
  type     = string
  nullable = false
  default  = "us-central1"
}

variable "google_project" {
  type     = string
  nullable = false
}

variable "google_default_labels" {
  type     = map(string)
  nullable = false
  default  = {}
}

variable "aws_region" {
  type     = string
  nullable = false
  default  = "us-east-1"
}

variable "aws_default_tags" {
  type     = map(string)
  nullable = false
  default  = {}
}

variable "aws_account_id" {
  type     = string
  nullable = false
}

# variable "aws_web_identity_token_file" {
#   type      = string
#   nullable  = true
#   sensitive = true
#   default   = null
# }

variable "image" {
  type     = string
  nullable = false
  default  = "us-docker.pkg.dev/cloudrun/container/hello"
}
