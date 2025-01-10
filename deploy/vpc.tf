resource "google_compute_network" "myVPC" {
  name                    = "my-vpc"
  project                 = google_project.myProject.name
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute_engine]
}

resource "google_compute_subnetwork" "us-central1" {
  name                     = "us-central1"
  region                   = "us-central1"
  ip_cidr_range            = "10.0.0.0/16"
  network                  = google_compute_network.myVPC.id
  project                  = google_project.myProject.name
  private_ip_google_access = true
}