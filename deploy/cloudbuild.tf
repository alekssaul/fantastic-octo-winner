resource "google_service_account" "cloudbuild" {
  project      = google_project.myProject.project_id
  account_id   = "sa-cloudbuild"
  display_name = "Service Account for Cloud Build"
}

resource "google_project_iam_member" "cloudbuild_act_as" {
  project = google_project.myProject.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_project_iam_member" "cloudbuild_dockerpush" {
  project = google_project.myProject.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_project_iam_member" "cloudbuild_logs_writer" {
  project = google_project.myProject.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudbuild.email}"
}

resource "google_secret_manager_secret" "github-token-secret" {
  project   = google_project.myProject.project_id
  secret_id = "github-token-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "github-token-secret-version" {
  secret      = google_secret_manager_secret.github-token-secret.id
  secret_data = file("../secrets/my-github-token.txt")
  depends_on  = [google_project_service.secretmanager]
}

data "google_iam_policy" "p4sa-secretAccessor" {
  binding {
    role    = "roles/secretmanager.secretAccessor"
    members = ["serviceAccount:service-${google_project.myProject.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"]
  }
}

resource "google_secret_manager_secret_iam_policy" "policy" {
  project     = google_project.myProject.project_id
  secret_id   = google_secret_manager_secret.github-token-secret.secret_id
  policy_data = data.google_iam_policy.p4sa-secretAccessor.policy_data
}

resource "google_cloudbuildv2_connection" "github" {
  project  = google_project.myProject.project_id
  location = "us-central1"
  name     = "github"

  github_config {
    app_installation_id = var.github_installationid
    authorizer_credential {
      oauth_token_secret_version = google_secret_manager_secret_version.github-token-secret-version.id
    }
  }
}

resource "google_cloudbuildv2_repository" "my-repository" {
  project           = google_project.myProject.project_id
  location          = "us-central1"
  name              = "my-repo"
  parent_connection = google_cloudbuildv2_connection.github.name
  remote_uri        = var.github_repo
}


resource "google_cloudbuild_trigger" "backend" {
  location        = "us-central1"
  name            = "backend"
  description     = "Backend build"
  project         = google_project.myProject.project_id
  service_account = google_service_account.cloudbuild.id
  repository_event_config {
    repository = google_cloudbuildv2_repository.my-repository.id
    push {
      branch = ".*"
    }
  }

  depends_on = [
    google_project_iam_member.cloudbuild_act_as,
    google_project_iam_member.cloudbuild_logs_writer
  ]

  build {
    options {
      logging = "CLOUD_LOGGING_ONLY"

    }
    step {
      name   = "gcr.io/cloud-builders/docker"
      script = "docker build -t ${google_artifact_registry_repository.docker.location}-docker.pkg.dev/${google_artifact_registry_repository.docker.project}/${google_artifact_registry_repository.docker.name}/backend:main ./src/backend"
    }
    artifacts {
      images = [
        "${google_artifact_registry_repository.docker.location}-docker.pkg.dev/${google_artifact_registry_repository.docker.project}/${google_artifact_registry_repository.docker.name}/backend:main"
      ]
    }

  }
}