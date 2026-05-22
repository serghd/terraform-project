output "postgres_connection" {
  value = "postgresql://${var.postgres_user}:***@localhost:5432/${var.postgres_db}"
}

output "redis_connection" {
  value = "redis://localhost:6379"
}