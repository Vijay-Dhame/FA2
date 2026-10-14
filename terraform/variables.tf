# ---------------------------------------------------------------------------
# variables.tf — Typed and documented input variables
# ---------------------------------------------------------------------------

variable "environment_name" {
  description = "Name of the deployment environment (qa, uat, prod)."
  type        = string

  validation {
    condition     = contains(["qa", "uat", "prod"], var.environment_name)
    error_message = "environment_name must be one of: qa, uat, prod."
  }
}

variable "frontend_host_port" {
  description = "Host port mapped to the frontend container (port 80)."
  type        = number

  validation {
    condition     = var.frontend_host_port >= 1024 && var.frontend_host_port <= 65535
    error_message = "frontend_host_port must be between 1024 and 65535."
  }
}

variable "backend_host_port" {
  description = "Host port mapped to the backend container (port 8000)."
  type        = number

  validation {
    condition     = var.backend_host_port >= 1024 && var.backend_host_port <= 65535
    error_message = "backend_host_port must be between 1024 and 65535."
  }
}

variable "frontend_image_name" {
  description = "Docker image name for the frontend."
  type        = string
  default     = "devops-env-manager-frontend"
}

variable "backend_image_name" {
  description = "Docker image name for the backend."
  type        = string
  default     = "devops-env-manager-backend"
}

variable "frontend_image_tag" {
  description = "Tag for the frontend Docker image."
  type        = string
  default     = "latest"
}

variable "backend_image_tag" {
  description = "Tag for the backend Docker image."
  type        = string
  default     = "latest"
}
