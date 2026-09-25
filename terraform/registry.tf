resource "google_artifact_registry_repository" "this" {
  location               = var.google_region
  repository_id          = "containers"
  format                 = "DOCKER"
  cleanup_policy_dry_run = true

  cleanup_policies {
    id     = "keep-latest"
    action = "KEEP"
    condition {
      tag_state    = "TAGGED"
      tag_prefixes = ["latest"]
    }
  }

  cleanup_policies {
    id     = "keep-recent"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }

  cleanup_policies {
    id     = "delete-old"
    action = "DELETE"
    condition {
      older_than = "30d"
    }
  }
}

data "google_artifact_registry_docker_image" "latest" {
  location      = var.google_region
  repository_id = google_artifact_registry_repository.this.repository_id
  image_name    = "${local.name}:latest"
}
