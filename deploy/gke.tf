# Deploy a private GKE Cluster

resource "google_service_account" "gke" {
  count        = var.use_cloudrun ? 0 : 1 # Only create if use_cloudrun is false
  project      = google_project.myProject.project_id
  account_id   = "sa-gke"
  display_name = "Service Account for GKE"
}

resource "google_container_cluster" "primary" {
  count               = var.use_cloudrun ? 0 : 1 # Only create if use_cloudrun is false
  project             = google_project.myProject.project_id
  network             = google_compute_network.myVPC.id
  subnetwork          = google_compute_subnetwork.us-central1.id
  enable_autopilot    = var.gke_autopilot
  name                = "my-gke-cluster"
  location            = "us-central1"
  deletion_protection = false
  ##remove_default_node_pool = false
  initial_node_count = 1

  private_cluster_config {
    enable_private_nodes = true
  }

  node_config {
    shielded_instance_config {
      enable_secure_boot = true
    }
  }
}


