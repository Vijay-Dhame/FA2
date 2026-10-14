# ---------------------------------------------------------------------------
# main.tf — Shared resource definitions for all environments
#
# One set of resource blocks provisions any environment.
# The environment_name variable drives naming, networking, and port mapping.
# Terraform workspace or per-environment state file isolates state.
# ---------------------------------------------------------------------------

# ---- Docker network (one per environment) ---------------------------------

resource "docker_network" "env_network" {
  name = "devops-em-${var.environment_name}-network"
}

# ---- Docker images --------------------------------------------------------
# The images must be pre-built with `docker build` before running Terraform.
# Terraform references the locally available image by name:tag.

resource "docker_image" "frontend" {
  name         = "${var.frontend_image_name}:${var.frontend_image_tag}"
  keep_locally = true
}

resource "docker_image" "backend" {
  name         = "${var.backend_image_name}:${var.backend_image_tag}"
  keep_locally = true
}

# ---- Backend container ----------------------------------------------------

resource "docker_container" "backend" {
  name  = "devops-em-${var.environment_name}-backend"
  image = docker_image.backend.image_id

  ports {
    internal = 8000
    external = var.backend_host_port
  }

  networks_advanced {
    name = docker_network.env_network.name
    aliases = ["backend"]
  }

  env = [
    "ENVIRONMENT_NAME=${var.environment_name}",
    "SERVICE_NAME=backend",
  ]

  restart = "unless-stopped"

  # Ensure network is created first
  depends_on = [docker_network.env_network]
}

# ---- Frontend container ---------------------------------------------------

resource "docker_container" "frontend" {
  name  = "devops-em-${var.environment_name}-frontend"
  image = docker_image.frontend.image_id

  ports {
    internal = 80
    external = var.frontend_host_port
  }

  networks_advanced {
    name = docker_network.env_network.name
  }

  restart = "unless-stopped"

  depends_on = [
    docker_network.env_network,
    docker_container.backend,
  ]
}
