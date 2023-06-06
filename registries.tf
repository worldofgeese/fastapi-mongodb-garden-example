variable "project_id" {
  description = "The Google Cloud project ID"
}

locals {
  random_suffix = random_id.suffix.hex
}

resource "random_id" "suffix" {
  byte_length = 4
}

provider "google" {
  project = var.project_id
}

resource "google_artifact_registry_repository" "gcp_repo" {
  provider = google
  location = "europe-west3"
  repository_id = "gcp-repository-${local.random_suffix}"
  format = "DOCKER"
}

output "gcp_repository_url" {
  value = "${google_artifact_registry_repository.gcp_repo.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.gcp_repo.repository_id}"

}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_ecr_repository" "aws_repository" {
  name = "aws-repository-${local.random_suffix}"
}

output "aws_repository_url" {
  value = aws_ecr_repository.aws_repository.repository_url
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "acr_resource_group" {
  name = "acr-resource-group"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr_registry" {
  name = "acrregistry${local.random_suffix}"
  resource_group_name = azurerm_resource_group.acr_resource_group.name
  location = azurerm_resource_group.acr_resource_group.location
  sku = "Basic"
  admin_enabled = true
}

output "acr_registry_url" {
  value = azurerm_container_registry.acr_registry.login_server
}

resource "google_storage_bucket" "default" {
  name          = "bucket-tfstate-${local.random_suffix}"
  force_destroy = false
  location      = "EU"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}

terraform {
 backend "gcs" {
   bucket  = "bucket-tfstate-231954e9"
   prefix  = "terraform/state"
 }
}
