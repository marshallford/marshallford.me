terraform {
  required_version = ">= 1.3.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
  backend "s3" {
    bucket         = "mford-shared-infrastructure-prod-terraform-state"
    key            = "marshallford-me"
    dynamodb_table = "terraform-state"
    profile        = "terraform-state"
    region         = "us-east-1"
  }
}

locals {
  terraform_config = "marshallford-me"
  google_default_labels = merge(var.google_default_labels, {
    Repository      = var.repository
    Automation      = "terraform"
    TerraformConfig = local.terraform_config
  })
  aws_default_tags = merge(var.aws_default_tags, {
    Repository      = var.repository
    Automation      = "terraform"
    TerraformConfig = local.terraform_config
  })
  aws_role_arn = "arn:aws:iam::${var.aws_account_id}:role/pipeline-${local.terraform_config}-iac"
}

provider "google" {
  region  = var.google_region
  project = var.google_project
}

provider "aws" {
  dynamic "assume_role" {
    for_each = var.aws_web_identity_token_file == null ? [1] : []
    content {
      role_arn = local.aws_role_arn
    }
  }
  dynamic "assume_role_with_web_identity" {
    for_each = var.aws_web_identity_token_file != null ? [1] : []
    content {
      role_arn                = local.aws_role_arn
      web_identity_token_file = var.aws_web_identity_token_file
    }
  }
  region = var.aws_region
  default_tags {
    tags = local.aws_default_tags
  }
}
