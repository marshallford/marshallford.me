terraform {
  required_version = ">= 1.16.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "8.3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
  backend "s3" {
    bucket       = "mford-shared-infrastructure-prod-terraform-state"
    key          = "marshallford-me"
    use_lockfile = true
    profile      = "terraform-state"
    region       = "us-east-1"
  }
}

locals {
  terraform_config = "marshallford-me"
  name             = replace(var.domain, ".", "-")
  google_default_labels = merge(var.google_default_labels, {
    repository       = replace(replace(var.repository, "/", "_"), ".", "-")
    automation       = "terraform"
    terraform-config = local.terraform_config
  })
  aws_default_tags = merge(var.aws_default_tags, {
    Repository      = var.repository
    Automation      = "terraform"
    TerraformConfig = local.terraform_config
  })
}

provider "google" {
  region         = var.google_region
  project        = var.google_project
  default_labels = local.google_default_labels
}

provider "aws" {
  profile = "marshallford-me"
  region  = var.aws_region
  default_tags {
    tags = local.aws_default_tags
  }
}
