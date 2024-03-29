resource "google_cloud_run_v2_service" "this" {
  name     = replace(data.aws_route53_zone.this.name, ".", "-")
  location = var.google_region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = 1
      max_instance_count = 2
    }
    containers {
      image = var.image
      env {
        name  = "NGINX_HOST"
        value = data.aws_route53_zone.this.name
      }
      env {
        name  = "REGION"
        value = var.google_region
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
  # deploy with gcloud run deploy
  # https://github.com/hashicorp/terraform-provider-google/issues/13410#issuecomment-1404610413
  # lifecycle {
  #   ignore_changes = [
  #     annotations["client.knative.dev/user-image"],
  #     client,
  #     client_version,
  #     template[0].annotations["client.knative.dev/user-image"],
  #     template[0].revision,
  #     template[0].containers[0].image,
  #   ]
  # }
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
  name     = data.aws_route53_zone.this.name
  location = google_cloud_run_v2_service.this.location
  metadata {
    namespace = var.google_project
  }
  spec {
    route_name = google_cloud_run_v2_service.this.name
  }
}

resource "google_cloud_run_domain_mapping" "www" {
  name     = "www.${data.aws_route53_zone.this.name}"
  location = google_cloud_run_v2_service.this.location
  metadata {
    namespace = var.google_project
  }
  spec {
    route_name = google_cloud_run_v2_service.this.name
  }
}
