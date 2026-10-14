# ---------------------------------------------------------------------------
# outputs.tf — Useful values exposed after Terraform apply
# ---------------------------------------------------------------------------

output "environment_name" {
  description = "The deployed environment."
  value       = var.environment_name
}

output "frontend_url" {
  description = "URL to access the frontend in a browser."
  value       = "http://localhost:${var.frontend_host_port}"
}

output "backend_url" {
  description = "URL to access the backend API."
  value       = "http://localhost:${var.backend_host_port}"
}

output "frontend_container_name" {
  description = "Name of the running frontend container."
  value       = docker_container.frontend.name
}

output "backend_container_name" {
  description = "Name of the running backend container."
  value       = docker_container.backend.name
}

output "docker_network_name" {
  description = "Name of the environment-specific Docker network."
  value       = docker_network.env_network.name
}
