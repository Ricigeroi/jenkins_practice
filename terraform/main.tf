provider "google" {
  credentials = file(var.service_account_key)
  project     = var.project
  region      = var.region
}

resource "google_compute_instance" "vm_instance" {
  name         = "docker-vm"
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
      // Делает VM доступной из интернета
    }
  }

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
sudo docker run -d -p 80:80 ${var.image_name}
EOF
}
