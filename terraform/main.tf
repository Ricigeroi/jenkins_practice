provider "google" {
  credentials = file(var.service_account_key)
  project     = var.project
  region      = var.region
}

# Создаем сервисный аккаунт для VM
resource "google_service_account" "flask_vm_sa" {
  account_id   = "flask-vm-sa"
  display_name = "Service Account for Flask VM"
}

# Назначаем роль Artifact Registry Reader сервисному аккаунту
resource "google_project_iam_member" "flask_vm_sa_artifact_registry" {
  project = var.project
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.flask_vm_sa.email}"
}

# Назначаем разрешение на скачивание артефактов из Artifact Registry
resource "google_artifact_registry_repository_iam_member" "flask_vm_sa_pull" {
  project    = var.project
  location   = "europe-north1"
  repository = "jenkins-practice"
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.flask_vm_sa.email}"
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

  tags = ["flask-server", "http-server", "https-server"]

  # Привязываем сервисный аккаунт к VM
  service_account {
    email  = google_service_account.flask_vm_sa.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOF
#!/bin/bash
# Устанавливаем Docker
sudo apt update && sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Авторизуемся в Artifact Registry
gcloud auth configure-docker europe-north1-docker.pkg.dev

# Загружаем и запускаем контейнер
sudo docker pull ${var.image_name}
sudo docker run -d -p 5000:5000 ${var.image_name}
EOF
}

# Firewall-правило для Flask (порт 5000)
resource "google_compute_firewall" "allow_flask" {
  name    = "allow-flask"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["5000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["flask-server"]
}

# Firewall-правило для HTTP (порт 80)
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

# Firewall-правило для HTTPS (порт 443)
resource "google_compute_firewall" "allow_https" {
  name    = "allow-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["https-server"]
}
