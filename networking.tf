resource "google_compute_network" "cr460" {
    name                    = "cr460"
    auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "public" {
    name          = "public"
    ip_cidr_range = "172.16.1.0/24"
    network       = "${google_compute_network.cr460.self_link}"
    region        = "us-east1"
}

resource "google_compute_subnetwork" "workload" {
    name          = "workload"
    ip_cidr_range = "10.0.1.0/24"
    network       = "${google_compute_network.cr460.self_link}"
    region        = "us-east1"
}

resource "google_compute_subnetwork" "backend" {
    name          = "backend"
    ip_cidr_range = "10.0.2.0/24"
    network       = "${google_compute_network.cr460.self_link}"
    region        = "us-east1"
}

resource "google_compute_firewall" "public-firewall" {
    name = "public-firewall"
    network = "${google_compute_network.cr460.name}"
    allow {
        protocol = "tcp"
        ports = ["22", "80", "443"]
    }
    target_tags = ["public-node"]
}

resource "google_compute_firewall" "public-workload-firewall" {
    name = "public-workload-firewall"
    network = "${google_compute_network.cr460.name}"
    allow {
        protocol = "tcp"
        ports = ["22"]
    }
    source_tags = ["public-node"]
    target_tags = ["workload-node"]
}

resource "google_compute_firewall" "public-backend-firewall" {
    name = "public-backend-firewall"
    network = "${google_compute_network.cr460.name}"
    allow {
        protocol = "tcp"
        ports = ["22", "2379", "2380"]
    }
    source_tags = ["public-node"]
    target_tags = ["backend-node"]
}

resource "google_compute_firewall" "workload-backend-firewall" {
    name = "workload-backend-firewall"
    network = "${google_compute_network.cr460.name}"
    allow {
        protocol = "tcp"
        ports = ["22", "2379", "2380"]
    }
    source_tags = ["workload-node"]
    target_tags = ["backend-node"]
}

resource "google_dns_managed_zone" "beauchef" {
  name     = "beauchef"
  dns_name = "beauchef.cr460lab.com."
}

resource "google_dns_record_set" "jump" {
    name = "jump.beauchef.cr460lab.com."
    type = "A"
    ttl = 300
    managed_zone = "cr460lab"
    rrdatas = ["${google_compute_instance.jumphost.network_interface.0.access_config.0.assigned_nat_ip}"]
}

resource "google_dns_record_set" "vault" {
    name = "vault.beauchef.cr460lab.com."
    type = "A"
    ttl = 300
    managed_zone = "cr460lab"
    rrdatas = ["${google_compute_instance.vaulthost.network_interface.0.access_config.0.assigned_nat_ip}"]
}
