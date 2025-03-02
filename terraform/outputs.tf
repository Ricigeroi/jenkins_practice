output "instance_ip" {
  description = "Public IP of the deployed VM"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
