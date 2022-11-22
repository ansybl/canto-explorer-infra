resource "random_id" "user-password" {
  keepers = {
    name = google_sql_database_instance.default.name
  }
  byte_length = 8
  depends_on  = [google_sql_database_instance.default]
}

resource "google_sql_user" "default" {
  name       = var.db_user
  project    = var.project
  instance   = google_sql_database_instance.default.name
  password   = var.db_password == "" ? random_id.user-password.hex : var.db_password
  depends_on = [google_sql_database_instance.default]
}

resource "google_sql_database_instance" "default" {
  name             = "${var.prefix}-default-sql-instance-${local.environment}"
  database_version = "POSTGRES_14"
  region           = var.region

  settings {
    tier = "db-custom-2-4096"

    database_flags {
      name  = "max_connections"
      value = 150
    }

    insights_config {
      query_insights_enabled  = true
      record_client_address   = true
      record_application_tags = true
    }
  }

  depends_on = [
    google_project_service.sqladmin
  ]
}

resource "google_sql_database" "db" {
  name     = "${var.prefix}-db-${local.environment}"
  project  = var.project
  instance = google_sql_database_instance.default.name
}
