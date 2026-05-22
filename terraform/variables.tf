variable "postgres_user" {
  type    = string
  default = "app_user"
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_db" {
  type    = string
  default = "notes_db"
}

variable "image_tag" {
  type    = string
  default = "dev"
}