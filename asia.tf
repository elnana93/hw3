

resource "google_compute_network" "asia_network" {
  name = "asia-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "asia_subnet" {
  name          = "asia-subnet"
  region        = "asia-east1"
  network       = google_compute_network.asia_network.self_link
  ip_cidr_range = "192.168.0.0/24"
}

resource "google_compute_firewall" "asia_firewall" {
  name    = "asia-firewall"
  network = google_compute_network.asia_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "asia_instance" {
  name         = "asia-instance"
  machine_type = "n2-standard-4"
  zone         = "asia-east1-a"

  boot_disk {
    initialize_params {
      image = "projects/windows-cloud/global/images/windows-server-2022-dc-v20240415"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.asia_subnet.self_link
    network = google_compute_network.asia_network.self_link
    access_config {}
  }
  
}



































































/*
# Define provider
provider "google" {
  credentials = file("path/to/your/credentials.json")
  project     = "your-project-id"
  region      = "us-central1"
}

# Create two custom VPC networks
resource "google_compute_network" "vpc_network1" {
  name = "vpc-network1"
}

resource "google_compute_network" "vpc_network2" {
  name = "vpc-network2"
}

# Create firewall rules in both VPCs
resource "google_compute_firewall" "firewall1" {
  name    = "firewall1"
  network = google_compute_network.vpc_network1.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "firewall2" {
  name    = "firewall2"
  network = google_compute_network.vpc_network2.name

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Create instances in each VPC
resource "google_compute_instance" "instance1" {
  name         = "instance1"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  network_interface {
    network = google_compute_network.vpc_network1.name
  }
}

resource "google_compute_instance" "instance2" {
  name         = "instance2"
  machine_type = "n1-standard-1"
  zone         = "us-central1-b"
  network_interface {
    network = google_compute_network.vpc_network2.name
  }
}

# Verify connectivity (Assuming ping is allowed by the firewall rules)
resource "null_resource" "ping_instance1_from_instance2" {
  provisioner "local-exec" {
    command = "ping -c 4 $(terraform output -json instance1_ip | jq -r '.[0]')"
  }
  depends_on = [google_compute_instance.instance1]
}

resource "null_resource" "ping_instance2_from_instance1" {
  provisioner "local-exec" {
    command = "ping -c 4 $(terraform output -json instance2_ip | jq -r '.[0]')"
  }
  depends_on = [google_compute_instance.instance2]
}

# Create VPNs for each network (Not implemented here as it requires external configuration)

# Create Static IPs for each network
resource "google_compute_address" "static_ip1" {
  name   = "static-ip1"
  region = "us-central1"
  network = google_compute_network.vpc_network1.self_link
}

resource "google_compute_address" "static_ip2" {
  name   = "static-ip2"
  region = "us-central1"
  network = google_compute_network.vpc_network2.self_link
}

# Set Forwarding Rules for each VPN Gateway (Not implemented here as it requires VPN configuration)

# Create Tunnels between each Gateway (Not implemented here as it requires VPN configuration)

# Create routes for each network
resource "google_compute_route" "route1" {
  name                  = "route1"
  network               = google_compute_network.vpc_network1.name
  destination_range     = "10.2.0.0/16"
  next_hop_gateway      = "default-internet-gateway"
}

resource "google_compute_route" "route2" {
  name                  = "route2"
  network               = google_compute_network.vpc_network2.name
  destination_range     = "10.3.0.0/16"
  next_hop_gateway      = "default-internet-gateway"
}
*/



























/*# Create VPN tunnel from Asia to Europe
resource "google_compute_vpn_tunnel" "asia_to_europe_vpn" {
  name                  = "asia-to-europe-vpn"
  region                = "europe-southwest1"  # Specify your desired Europe region

  peer_ip               = "34.175.174.87"  # Replace with Europe VPN gateway IP 34.175.174.87 ?
  shared_secret         = "abc123"    # Replace with your shared secret
  target_vpn_gateway    = google_compute_vpn_gateway.europe_vpn_gateway.id
  vpn_gateway           = google_compute_vpn_gateway.asia_vpn_gateway.id
}


*/

