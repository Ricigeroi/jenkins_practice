variable "project" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-north1"
}

variable "service_account_key" {
  description = "Google Cloud Service Account JSON Key (provided by Jenkins)"
  type        = string
}

variable "image_name" {
  description = "Docker Image from GAR"
  type        = string
}
