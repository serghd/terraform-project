resource "docker_network" "app_network" {
  name = "pet-network"
}

# -----------------------
# PostgreSQL
# -----------------------
resource "docker_container" "postgres" {
  name  = "terraform-postgres"
  image = "postgres:16"

  #restart = "unless-stopped"

  env = [
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_DB=${var.postgres_db}"
  ]

  networks_advanced {
   name = docker_network.app_network.name
  }
}

# -----------------------
# Redis
# -----------------------
resource "docker_container" "redis" {
  name  = "terraform-redis"
  image = "redis:8"

  #restart = "unless-stopped"

  networks_advanced {
    name = docker_network.app_network.name
  }
}

# -----------------------
# API image (build from local Dockerfile)
# -----------------------
resource "docker_image" "api" {
  name = "terraform-image-api:${var.image_tag}"

  build {
    context = "../app"
  }
}

# -----------------------
# API container
# -----------------------
resource "docker_container" "api" {
  name  = "terraform-api"
  image = docker_image.api.name

  #restart = "unless-stopped"

  ports {
    internal = 3000
    external = 3000
  }

  env = [
    "DB_HOST=terraform-postgres",
    "DB_USER=${var.postgres_user}",
    "DB_PASSWORD=${var.postgres_password}",
    "DB_NAME=${var.postgres_db}",
    "REDIS_HOST=terraform-redis"
  ]

  networks_advanced {
   name = docker_network.app_network.name
  }
  
  depends_on = [
    docker_container.postgres,
    docker_container.redis
  ]
}