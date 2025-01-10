# Creates a brand new project enables APIs and sets up billing for the project

resource "google_project" "myProject" {
  name            = "${var.project_prefix}-${random_string.project_id.result}"
  project_id      = "${var.project_prefix}-${random_string.project_id.result}"
  billing_account = var.project_billingaccount
  deletion_policy = "DELETE"
}

resource "random_string" "project_id" {
  length  = 8
  special = false
  lower   = true
  upper   = false
}

# APIs to enable
resource "google_project_service" "compute_engine" {
  project                    = google_project.myProject.project_id
  service                    = "compute.googleapis.com"
  disable_dependent_services = true
}

resource "google_project_service" "monitoring" {
  project = google_project.myProject.project_id
  service = "monitoring.googleapis.com"
}

resource "google_project_service" "logging" {
  project = google_project.myProject.project_id
  service = "logging.googleapis.com"
}

resource "google_project_service" "cloudbuild" {
  project = google_project.myProject.project_id
  service = "cloudbuild.googleapis.com"
}

resource "google_project_service" "gke" {
  project = google_project.myProject.project_id
  service = "container.googleapis.com"
}

resource "google_project_service" "secretmanager" {
  project = google_project.myProject.project_id
  service = "secretmanager.googleapis.com"
}