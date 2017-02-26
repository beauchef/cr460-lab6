resource "google_compute_instance" "jumphost" {
    name = "jumphost"
    machine_type = "f1-micro"
    zone = "us-east1-b"
    tags = ["public-node"]

    disk {
        image = "debian-cloud/debian-8"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.public.name}"
        access_config {}
    }

    metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
}

resource "google_compute_instance" "vaulthost" {
    name = "vaulthost"
    machine_type = "f1-micro"
    zone = "us-east1-b"
    tags = ["public-node"]

    disk {
        image = "coreos-cloud/coreos-stable"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.public.name}"
        access_config {}
    }
}

resource "google_compute_instance" "master" {
    name = "master"
    machine_type = "f1-micro"
    zone = "us-east1-b"
    tags = ["workload-node"]

    disk {
        image = "coreos-cloud/coreos-stable"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.workload.name}"
    }

    metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
}

resource "google_compute_instance_template" "worker" {
  name                 = "worker"
  machine_type         = "f1-micro"
  can_ip_forward       = false
  tags = ["workload-node"]

  disk {
    source_image = "coreos-cloud/coreos-stable"
    auto_delete = true
    boot = true
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.workload.name}"
  }
}

resource "google_compute_instance_group_manager" "workers" {
  name               = "workers"
  base_instance_name = "worker"
  instance_template  = "${google_compute_instance_template.worker.self_link}"
  zone               = "us-east1-b"
}

resource "google_compute_autoscaler" "workscaler" {
  name   = "workscaler"
  zone   = "us-east1-b"
  target = "${google_compute_instance_group_manager.workers.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_instance" "etcd1" {
    name                 = "etcd1"
    machine_type         = "f1-micro"
    zone                 = "us-east1-b"
    tags                 = ["backend-node"]

    disk {
        image = "coreos-cloud/coreos-stable"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.backend.name}"
    }
}

resource "google_compute_instance" "etcd2" {
    name                 = "etcd2"
    machine_type         = "f1-micro"
    zone                 = "us-east1-b"
    tags                 = ["backend-node"]

    disk {
        image = "coreos-cloud/coreos-stable"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.backend.name}"
    }
}

resource "google_compute_instance" "etcd3" {
    name                 = "etcd3"
    machine_type         = "f1-micro"
    zone                 = "us-east1-b"
    tags                 = ["backend-node"]

    disk {
        image = "coreos-cloud/coreos-stable"
    }

    network_interface {
        subnetwork = "${google_compute_subnetwork.backend.name}"
    }
}
