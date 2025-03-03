provider "google" {
  credentials = file(var.service_account_key)
  project     = var.project
  region      = var.region
}

resource "google_compute_instance" "vm_instance" {
  name         = "flask-app-vm"
  machine_type = "e2-micro"
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      network_tier = "STANDARD" # Используем стандартный уровень сервиса сети
    }
  }

  tags = ["flask-server"]

  metadata_startup_script = <<EOF
#!/bin/bash
# Устанавливаем Docker
sudo apt update && sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Авторизуемся в GAR
gcloud auth configure-docker ${var.region}-docker.pkg.dev

# Загружаем и запускаем контейнер
sudo docker pull ${var.image_name}
sudo docker run -d -p 5000:5000 ${var.image_name}
EOF
}

resource "google_compute_firewall" "allow_flask" {
  name    = "allow-flask-5000"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["flask-server"]
}
