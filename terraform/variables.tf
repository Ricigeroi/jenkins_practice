variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "gcp_credentials_file" {
  type = string
}

variable "artifact_image" {
  type        = string
  description = "Полный URI Docker-образа в Artifact Registry, например: us-central1-docker.pkg.dev/<PROJECT_ID>/<REPO>/<IMAGE_NAME>:latest"
}
