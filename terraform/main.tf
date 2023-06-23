terraform {
  backend "gcs" {
    bucket      = "canto-explorer-infra-bucket-tfstate"
    prefix      = "terraform/state"
    credentials = "../terraform-service-key.json"
  }
}

provider "google" {
  project     = var.project
  credentials = file(var.credentials)
  region      = var.region
  zone        = var.zone
}

provider "google-beta" {
  project     = var.project
  credentials = file(var.credentials)
  region      = var.region
  zone        = var.zone
}

resource "google_storage_bucket" "default" {
  name          = "canto-explorer-infra-bucket-tfstate"
  force_destroy = false
  location      = "US"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

resource "google_project_service" "cloud_run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "sqladmin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_cloud_run_service" "default" {
  name     = "${local.service_name}-run-service-${local.environment}"
  location = var.region
  provider = google-beta

  template {
    spec {
      containers {
        image   = "gcr.io/${var.project}/${local.image_name}:${var.image_tag}"
        command = ["/bin/bash"]
        args = [
          "-c",
          "bin/blockscout eval 'Elixir.Explorer.ReleaseTasks.create_and_migrate()' && bin/blockscout start"
        ]
        resources {
          limits = {
            cpu    = "4000m"
            memory = "8192Mi"
          }
        }
        ports {
          container_port = 4000
        }
        startup_probe {
          initial_delay_seconds = 60
          tcp_socket {
            port = 4000
          }
        }

        env {
          name  = "ETHEREUM_JSONRPC_VARIANT"
          value = "geth"
        }
        env {
          name  = "ETHEREUM_JSONRPC_HTTP_URL"
          value = var.ethereum_jsonrpc_http_url
        }
        env {
          # as in november 2022, the blockscout database URL parser crashes when using the unix socket url syntax
          # more specifically it seems to crash when not providing the host, so we're using the environments
          # breakdown below instead
          name  = "DATABASE_URL"
          value = ""
        }
        env {
          name  = "PGUSER"
          value = google_sql_user.default.name
        }
        env {
          name  = "PGPASSWORD"
          value = google_sql_user.default.password
        }
        env {
          name  = "PGHOST"
          value = "/cloudsql/${google_sql_database_instance.default.connection_name}"
        }
        env {
          name  = "PGDATABASE"
          value = google_sql_database.db.name
        }
        env {
          name  = "ETHEREUM_JSONRPC_TRACE_URL"
          value = var.ethereum_jsonrpc_http_url
        }
        env {
          name  = "NETWORK"
          value = ""
        }
        env {
          name  = "SUBNETWORK"
          value = "Canto"
        }
        env {
          name  = "LOGO"
          value = "/images/blockscout_logo.svg"
        }
        env {
          name  = "LOGO_FOOTER"
          value = "/images/blockscout_logo.svg"
        }
        env {
          name  = "ETHEREUM_JSONRPC_TRANSPORT"
          value = "http"
        }
        env {
          name  = "ETHEREUM_JSONRPC_DISABLE_ARCHIVE_BALANCES"
          value = false
        }
        env {
          name  = "IPC_PATH"
          value = ""
        }
        env {
          name  = "NETWORK_PATH"
          value = "/"
        }
        env {
          name  = "API_PATH"
          value = "/"
        }
        env {
          name  = "SOCKET_ROOT"
          value = "/"
        }
        env {
          name  = "BLOCKSCOUT_HOST"
          value = ""
        }
        env {
          name  = "BLOCKSCOUT_PROTOCOL"
          value = ""
        }
        env {
          name  = "COIN_NAME"
          value = ""
        }
        env {
          name  = "EMISSION_FORMAT"
          value = "DEFAULT"
        }
        env {
          name  = "COIN"
          value = ""
        }
        env {
          name  = "EXCHANGE_RATES_COIN"
          value = ""
        }
        env {
          name  = "POOL_SIZE"
          value = 40
        }
        env {
          name  = "POOL_SIZE_API"
          value = 10
        }
        env {
          name  = "ACCOUNT_POOL_SIZE"
          value = 10
        }
        env {
          name  = "ECTO_USE_SSL"
          value = false
        }
        env {
          name  = "HEART_BEAT_TIMEOUT"
          value = 30
        }
        env {
          name  = "BLOCKSCOUT_VERSION"
          value = ""
        }
        env {
          name  = "RELEASE_LINK"
          value = ""
        }
        env {
          name  = "BLOCK_TRANSFORMER"
          value = "base"
        }
        env {
          name  = "LINK_TO_OTHER_EXPLORERS"
          value = false
        }
        env {
          name  = "OTHER_EXPLORERS"
          value = "{}"
        }
        env {
          name  = "SUPPORTED_CHAINS"
          value = "{}"
        }
        env {
          name  = "CACHE_BLOCK_COUNT_PERIOD"
          value = 7200
        }
        env {
          name  = "CACHE_TXS_COUNT_PERIOD"
          value = 7200
        }
        env {
          name  = "CACHE_ADDRESS_COUNT_PERIOD"
          value = 7200
        }
        env {
          name  = "CACHE_ADDRESS_SUM_PERIOD"
          value = 3600
        }
        env {
          name  = "CACHE_TOTAL_GAS_USAGE_PERIOD"
          value = 3600
        }
        env {
          name  = "CACHE_ADDRESS_TRANSACTIONS_GAS_USAGE_COUNTER_PERIOD"
          value = 1800
        }
        env {
          name  = "CACHE_TOKEN_HOLDERS_COUNTER_PERIOD"
          value = 3600
        }
        env {
          name  = "CACHE_TOKEN_TRANSFERS_COUNTER_PERIOD"
          value = 3600
        }
        env {
          name  = "CACHE_ADDRESS_WITH_BALANCES_UPDATE_INTERVAL"
          value = 1800
        }
        env {
          name  = "CACHE_AVERAGE_BLOCK_PERIOD"
          value = 1800
        }
        env {
          name  = "CACHE_MARKET_HISTORY_PERIOD"
          value = 21600
        }
        env {
          name  = "CACHE_ADDRESS_TRANSACTIONS_COUNTER_PERIOD"
          value = 1800
        }
        env {
          name  = "CACHE_ADDRESS_TOKENS_USD_SUM_PERIOD"
          value = 1800
        }
        env {
          name  = "CACHE_ADDRESS_TOKEN_TRANSFERS_COUNTER_PERIOD"
          value = 1800
        }
        env {
          name  = "CACHE_BRIDGE_MARKET_CAP_UPDATE_INTERVAL"
          value = 1800
        }
        env {
          name  = "CACHE_TOKEN_EXCHANGE_RATE_PERIOD"
          value = 1800
        }
        env {
          name  = "TOKEN_METADATA_UPDATE_INTERVAL"
          value = 172800
        }
        env {
          name  = "ALLOWED_EVM_VERSIONS"
          value = "homestead,tangerineWhistle,spuriousDragon,byzantium,constantinople,petersburg,istanbul,berlin,london,default"
        }
        env {
          name  = "UNCLES_IN_AVERAGE_BLOCK_TIME"
          value = false
        }
        env {
          name  = "DISABLE_WEBAPP"
          value = false
        }
        env {
          name  = "DISABLE_READ_API"
          value = false
        }
        env {
          name  = "DISABLE_WRITE_API"
          value = false
        }
        env {
          name  = "DISABLE_INDEXER"
          value = false
        }
        env {
          name  = "DISABLE_REALTIME_INDEXER"
          value = false
        }
        env {
          name  = "DISABLE_TOKEN_INSTANCE_FETCHER"
          value = true
        }
        env {
          name  = "INDEXER_DISABLE_PENDING_TRANSACTIONS_FETCHER"
          value = false
        }
        env {
          name  = "INDEXER_DISABLE_INTERNAL_TRANSACTIONS_FETCHER"
          value = false
        }
        env {
          name  = "WOBSERVER_ENABLED"
          value = false
        }
        env {
          name  = "SHOW_ADDRESS_MARKETCAP_PERCENTAGE"
          value = true
        }
        env {
          name  = "CHECKSUM_ADDRESS_HASHES"
          value = true
        }
        env {
          name  = "CHECKSUM_FUNCTION"
          value = "eth"
        }
        env {
          name  = "DISABLE_EXCHANGE_RATES"
          value = true
        }
        env {
          name  = "DISABLE_KNOWN_TOKENS"
          value = false
        }
        env {
          name  = "ENABLE_TXS_STATS"
          value = true
        }
        env {
          name  = "SHOW_PRICE_CHART"
          value = false
        }
        env {
          name  = "SHOW_TXS_CHART"
          value = true
        }
        env {
          name  = "HISTORY_FETCH_INTERVAL"
          value = 30
        }
        env {
          name  = "TXS_HISTORIAN_INIT_LAG"
          value = 0
        }
        env {
          name  = "TXS_STATS_DAYS_TO_COMPILE_AT_INIT"
          value = 10
        }
        env {
          name  = "COIN_BALANCE_HISTORY_DAYS"
          value = 90
        }
        env {
          name  = "APPS_MENU"
          value = true
        }
        env {
          name  = "EXTERNAL_APPS"
          value = "[]"
        }
        env {
          name  = "SHOW_MAINTENANCE_ALERT"
          value = false
        }
        env {
          name  = "MAINTENANCE_ALERT_MESSAGE"
          value = ""
        }
        env {
          name  = "CUSTOM_CONTRACT_ADDRESSES_TEST_TOKEN"
          value = ""
        }
        env {
          name  = "ENABLE_SOURCIFY_INTEGRATION"
          value = false
        }
        env {
          name  = "SOURCIFY_SERVER_URL"
          value = ""
        }
        env {
          name  = "SOURCIFY_REPO_URL"
          value = ""
        }
        env {
          name  = "CHAIN_ID"
          value = ""
        }
        env {
          name  = "MAX_SIZE_UNLESS_HIDE_ARRAY"
          value = 50
        }
        env {
          name  = "HIDE_BLOCK_MINER"
          value = false
        }
        env {
          name  = "DISPLAY_TOKEN_ICONS"
          value = false
        }
        env {
          name  = "SHOW_TENDERLY_LINK"
          value = false
        }
        env {
          name  = "TENDERLY_CHAIN_PATH"
          value = ""
        }
        env {
          name  = "MAX_STRING_LENGTH_WITHOUT_TRIMMING"
          value = 2040
        }
        env {
          name  = "RE_CAPTCHA_SECRET_KEY"
          value = ""
        }
        env {
          name  = "RE_CAPTCHA_CLIENT_KEY"
          value = ""
        }
        env {
          name  = "JSON_RPC"
          value = ""
        }
        env {
          name  = "API_RATE_LIMIT"
          value = 50
        }
        env {
          name  = "API_RATE_LIMIT_BY_KEY"
          value = 50
        }
        env {
          name  = "API_RATE_LIMIT_BY_IP"
          value = 50
        }
        env {
          name  = "API_RATE_LIMIT_WHITELISTED_IPS"
          value = ""
        }
        env {
          name  = "API_RATE_LIMIT_STATIC_API_KEY"
          value = ""
        }
        env {
          name  = "FETCH_REWARDS_WAY"
          value = "trace_block"
        }
        env {
          name  = "ENABLE_RUST_VERIFICATION_SERVICE"
          value = true
        }
        env {
          name  = "RUST_VERIFICATION_SERVICE_URL"
          value = "http://host.docker.internal:8043/"
        }
        env {
          name  = "ACCOUNT_CLOAK_KEY"
          value = ""
        }
        env {
          name  = "ACCOUNT_ENABLED"
          value = false
        }
      }
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.default.connection_name
      }

      labels = {
        environment  = local.environment
        service_name = local.service_name
        prefix       = var.prefix
      }

    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_project_service.cloud_run_api
  ]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
