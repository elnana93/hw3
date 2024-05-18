








# Create VPN gateways in each region
resource "google_compute_vpn_gateway" "asia_vpn_gateway" {
  name    = "asia-vpn-gateway"
  network = google_compute_network.asia_network.self_link
  region  = "asia-east1"
}

resource "google_compute_vpn_gateway" "euro_vpn_gateway" {
  name    = "euro-vpn-gateway"
  network = google_compute_network.private_network.self_link
  region  = "europe-southwest1"
}

# Create VPNs for each network (Not implemented here as it requires external configuration)
# Create Static IPs for each network
resource "google_compute_address" "euro_static_ip" {
  name   = "euro-static-ip"
  region = "europe-southwest1"
}

resource "google_compute_address" "asia_static_ip" {
  name   = "asia-static-ip"
  region = "asia-east1"
}

#_______________________________________________________________
# Create VPN tunnel between Asia and Euro VPN gateways

# Create VPN tunnel between Asia and Euro VPN gateways
resource "google_compute_vpn_tunnel" "asia_to_euro_tunnel" {
  name               = "asia-to-euro-tunnel"
  region             = "asia-east1"
  target_vpn_gateway = google_compute_vpn_gateway.asia_vpn_gateway.id
  peer_ip            = google_compute_address.euro_static_ip.address # Euro VPN static IP
  shared_secret      = var.secret                                   # Replace with your shared secret .secret_data?
  ike_version        = 2

  local_traffic_selector  = ["192.168.0.0/24"]
  remote_traffic_selector = ["10.0.0.0/24"]


  depends_on = [

    google_compute_forwarding_rule.asia_esp,
    google_compute_forwarding_rule.asia_udp_500,
    google_compute_forwarding_rule.asia_udp_4500
  ]

}

#route traffic from asia to euro
resource "google_compute_route" "asia_to_euro_route" {
  name                = "asia-to-euro-route"
  network             = google_compute_network.asia_network.self_link
  dest_range          = "10.0.0.0/24"
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.asia_to_euro_tunnel.id
  priority            = 1000

}



#Fowarding Rule to Link Gatway to Generated IP
resource "google_compute_forwarding_rule" "asia_esp" {
  name        = "asia-esp"
  region      = "asia-east1"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.asia_static_ip.address
  target      = google_compute_vpn_gateway.asia_vpn_gateway.self_link
}


#UPD 500 traffic Rule
resource "google_compute_forwarding_rule" "asia_udp_500" {
  name        = "rule-2"
  region      = "asia-east1"
  ip_protocol = "UDP"
  ip_address  = google_compute_address.asia_static_ip.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.asia_vpn_gateway.self_link
}
#>>>

#UDP 4500 traffic rule
resource "google_compute_forwarding_rule" "asia_udp_4500" {
  name        = "rule-3"
  region      = "asia-east1"
  ip_protocol = "UDP"
  ip_address  = google_compute_address.asia_static_ip.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.asia_vpn_gateway.self_link
}

#_______________________________________________________________
#Do the reverse for the Euro VPN Gateway
#Reverse to connect Euro to Asia

/*
"10.0.0.0/24"
euro_static_ip
"europe-southwest1"
"euro_vpn_gateway"

"asia_static_ip"

private_network
*/



resource "google_compute_vpn_tunnel" "euro_to_asia_tunnel" {
  name               = "euro-to-asia-tunnel"
  region             = "europe-southwest1"
  target_vpn_gateway = google_compute_vpn_gateway.euro_vpn_gateway.id
  peer_ip            = google_compute_address.asia_static_ip.address # Euro VPN static IP
  shared_secret      = var.secret                                # Replace with your shared secret .secret_data?
  ike_version        = 2

  local_traffic_selector  = ["10.0.0.0/24"]
  remote_traffic_selector = ["192.168.0.0/24"]


  depends_on = [

    google_compute_forwarding_rule.euro_esp,
    google_compute_forwarding_rule.euro_udp_500,
    google_compute_forwarding_rule.euro_udp_4500
  ]

}

#route traffic from asia to euro
resource "google_compute_route" "euro_to_asia_route" {
  name                = "euro-to-asia-route"
  network             = google_compute_network.private_network.self_link
  dest_range          = "192.168.0.0/24"
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.euro_to_asia_tunnel.id
  priority            = 1000

}



#Fowarding Rule to Link Gatway to Generated IP
resource "google_compute_forwarding_rule" "euro_esp" {
  name        = "euro-esp"
  region      = "europe-southwest1"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.euro_static_ip.address
  target      = google_compute_vpn_gateway.euro_vpn_gateway.self_link
}


#UPD 500 traffic Rule
resource "google_compute_forwarding_rule" "euro_udp_500" {
  name        = "rule-12"
  region      = "europe-southwest1"
  ip_protocol = "UDP"
  ip_address  = google_compute_address.euro_static_ip.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.euro_vpn_gateway.self_link
}
#>>>

#UDP 4500 traffic rule
resource "google_compute_forwarding_rule" "euro_udp_4500" {
  name        = "rule-13"
  region      = "europe-southwest1"
  ip_protocol = "UDP"
  ip_address  = google_compute_address.euro_static_ip.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.euro_vpn_gateway.self_link
}



#i used a variable instead, because this did not work
/*
data "google_secret_manager_secret_version" "vpn_secret" {
  secret  = "vpn-shared-secret"
  version = "latest"
}*/
