## Service account variables

variable "credentials" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "prefix" {
  description = "Prefix to prepend to resource names."
  type        = string
  default     = ""
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "db_user" {
  type    = string
  default = "postgres"
}

variable "db_password" {
  type    = string
  default = ""
}

variable "create_load_balancer" {
  type    = bool
  default = false
}

variable "ethereum_jsonrpc_http_url" {
  type = string
}

locals {
  environment  = terraform.workspace
  service_name = "blockscout"
  image_name   = "${local.service_name}-${local.environment}"
}
