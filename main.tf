terraform {
  backend "gcs" {
    bucket = "marshallford-tf-state-marshallford-me"
  }
  required_providers {
    google = "~> 3.48"
  }
}

variable "image" {
  type = string
}

provider "google" {}

data "google_project" "project" {}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.website.location
  project     = google_cloud_run_service.website.project
  service     = google_cloud_run_service.website.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_service" "website" {
  name     = "marshallford-me"
  location = "us-central1"

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "5"
        "run.googleapis.com/client-name"   = "terraform"
      }
    }
    spec {
      containers {
        image = var.image
      }
      container_concurrency = 512 # nginx worker_connections/2
    }
  }
  autogenerate_revision_name = true
}

resource "google_cloud_run_domain_mapping" "website" {
  location = "us-central1"
  name     = "marshallford.me" # verified

  metadata {
    namespace = data.google_project.project.number
  }

  spec {
    route_name = google_cloud_run_service.website.name
  }
}
