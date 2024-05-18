terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.25.0"
    }
  }
}

provider "google" {
  # Configuration options

  project     = "class5-416923"
  credentials = "class5-416923-759a04e64c63.json"
  zone        = "europe-southwest1-a"
  region      = "europe-southwest1"  # Choose a suitable Europe region
}


#create one vpc with multiple subnets!!!!! ASAP!!!
#My rdp is allowed in europe



# Create a VPC network
resource "google_compute_network" "private_network" {
  name                    = "private-network"
  auto_create_subnetworks = false
}

# Create a subnet within the VPC network
resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.0.0/24" # RFC 1918 Private 10 net #10.0.0.0/24?
  network       = google_compute_network.private_network.self_link
  region        = "europe-southwest1"  # Same region as the VPC network
}

# Create a firewall rule to block all incoming traffic from the internet
resource "google_compute_firewall" "block_internet_access" {
  name    = "block-internet-access"
  network = google_compute_network.private_network.self_link

  deny {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/24", "172.16.1.0/24", "172.16.2.0/24", "192.168.0.0/24"]
}


# Create a GCP instance within the private subnet
resource "google_compute_instance" "private_instance" {
  name         = "private-instance"
  machine_type = "e2-medium"
  zone         = "europe-southwest1-a"  # Choose appropriate zone in Europe

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.self_link
    network = google_compute_network.private_network.self_link
    access_config {}
  }
}

