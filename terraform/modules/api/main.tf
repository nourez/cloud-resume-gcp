# Enable Cloud Run API for project
resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

# Deploy API to Cloud Run
resource "google_cloud_run_service" "api" {
  name     = "cloud-resume-api"
  location = "northamerica-northeast2"

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/resume-api:${var.image_tag}"
        args  = ["-projectID=${var.project_id}"]
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  autogenerate_revision_name = true

  depends_on = [google_project_service.run_api]
}

# Make API public
data "google_iam_policy" "api" {
  binding {
    role = "roles/run.invoker"

    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.api.location
  project  = google_cloud_run_service.api.project
  service  = google_cloud_run_service.api.name

  policy_data = data.google_iam_policy.api.policy_data
}
