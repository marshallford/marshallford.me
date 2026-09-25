locals {
  image_tag = one([for t in data.google_artifact_registry_docker_image.latest.tags : t if t != "latest"])
}

resource "google_service_account" "this" {
  account_id   = "${local.name}-runtime"
  display_name = "${var.domain} Cloud Run runtime"
}

resource "google_cloud_run_v2_service" "this" {
  name     = local.name
  location = var.google_region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.this.email
    timeout         = "30s"
    scaling {
      min_instance_count = 1
      max_instance_count = 2
    }
    containers {
      image = "${google_artifact_registry_repository.this.registry_uri}/${local.name}:${local.image_tag}"
      ports {
        name           = "h2c"
        container_port = 8080
      }
      env {
        name  = "SITE_HOST"
        value = var.domain
      }
      resources {
        cpu_idle          = true
        startup_cpu_boost = true
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }
      startup_probe {
        http_get {
          path = "/"
        }
      }
      liveness_probe {
        http_get {
          path = "/"
        }
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_binding" "this" {
  name     = google_cloud_run_v2_service.this.name
  location = google_cloud_run_v2_service.this.location
  role     = "roles/run.invoker"
  members = [
    "allUsers",
  ]
}

resource "google_cloud_run_domain_mapping" "apex" {
  name     = var.domain
  location = google_cloud_run_v2_service.this.location
  metadata {
    namespace = var.google_project
  }
  spec {
    route_name = google_cloud_run_v2_service.this.name
  }
}

resource "google_cloud_run_domain_mapping" "www" {
  name     = "www.${var.domain}"
  location = google_cloud_run_v2_service.this.location
  metadata {
    namespace = var.google_project
  }
  spec {
    route_name = google_cloud_run_v2_service.this.name
  }
}
