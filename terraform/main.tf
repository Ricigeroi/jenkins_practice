terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

resource "google_compute_instance" "myapp_instance" {
  name         = "myapp-instance"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network       = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Обновление пакетов и установка git, python3 и pip
    apt-get update -y
    apt-get install -y git python3 python3-pip

    # Клонируем репозиторий в /opt и переходим в директорию с приложением
    cd /opt
    git clone https://github.com/Ricigeroi/jenkins_practice.git
    cd jenkins_practice/app

    # Устанавливаем зависимости приложения
    pip3 install -r requirements.txt

    # Запускаем Flask-приложение в фоне и сохраняем лог
    nohup python3 app.py > /var/log/app.log 2>&1 &
  EOF
}
