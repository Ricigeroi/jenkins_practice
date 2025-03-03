provider "google" {
  credentials = file(var.service_account_key)
  project     = var.project
  region      = var.region
}

# Создаем статический внешний IP-адрес
resource "google_compute_address" "flask_vm_static_ip" {
  name         = "flask-vm-static-ip"
  region       = var.region
  network_tier = "STANDARD"
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

# Создаем виртуальную машину с постоянным IP
resource "google_compute_instance" "vm_instance" {
  name         = "flask-app-vm"
  machine_type = "e2-medium"
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip       = google_compute_address.flask_vm_static_ip.address
      network_tier = "STANDARD"
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
set -e

# Устанавливаем Docker (если его нет)
if ! command -v docker &> /dev/null
then
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Авторизуемся в Artifact Registry
gcloud auth configure-docker europe-north1-docker.pkg.dev

# Создаем deploy.sh
cat << 'EOS' > /home/deploy.sh
#!/bin/bash
set -e

echo "Stopping all running Docker containers..."
sudo docker stop $(sudo docker ps -q) || true

echo "Removing all Docker containers and images..."
sudo docker system prune -a -f

echo "Pulling the latest image..."
sudo docker pull ${var.image_name}

echo "Running the new container..."
sudo docker run -d -p 5000:5000 --restart always ${var.image_name}

echo "Deployment complete!"
EOS

# Даем права на выполнение deploy.sh
sudo chmod +x /home/deploy.sh

# Запускаем деплой при старте
sudo bash /home/deploy.sh
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
