variable "repository" {
  type     = string
  nullable = false
}

variable "domain" {
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
