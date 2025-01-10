resource "google_artifact_registry_repository" "docker" {
  project       = google_project.myProject.project_id
  location      = "us-central1"
  repository_id = "my-repository"
  description   = "Docker repo for the app"
  format        = "DOCKER"
}
