
resource "google_compute_network" "americas_network" {
  name = "americas-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "americas_subnet1" {
  name          = "americas-subnet1"
  region        = "southamerica-east1"
  network       = google_compute_network.americas_network.self_link
  ip_cidr_range = "172.16.1.0/24"
}

resource "google_compute_subnetwork" "americas_subnet2" {
  name          = "americas-subnet2"
  region        = "southamerica-west1"
  network       = google_compute_network.americas_network.self_link
  ip_cidr_range = "172.16.2.0/24"
}

resource "google_compute_firewall" "americas_firewall" {
  name    = "americas-firewall"
  network = google_compute_network.americas_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"] # Europe HQ RFC 1918 172.16 based subnets
}

# Create a GCP instance within the private subnet
resource "google_compute_instance" "americas_instance1" {
  name         = "americas-instance1"
  machine_type = "e2-medium"
  zone         = "southamerica-east1-b"  # South America1

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.americas_subnet1.self_link
    network = google_compute_network.americas_network.self_link
    access_config {}
  }
}


# Create a GCP instance within the private subnet
resource "google_compute_instance" "americas_instance2" {
  name         = "americas-instance2"
  machine_type = "e2-medium"
  zone         = "southamerica-west1-a"  # South America1

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.americas_subnet2.self_link
    network = google_compute_network.americas_network.self_link
    access_config {}
  }
}



#peering the 2 networks together

resource "google_compute_network_peering" "americas_to_europe_peering" {
  name                  = "americas-to-europe-peering"
  network               = google_compute_network.americas_network.id
  peer_network          = google_compute_network.private_network.id # Assuming you have a similar network resource for Europe
}


resource "google_compute_network_peering" "europe_to_americas_peering" {
  name                  = "europe-to-americas-peering"
  network               = google_compute_network.private_network.id
  peer_network          = google_compute_network.americas_network.id # Assuming you have a similar network resource for Europe
}
