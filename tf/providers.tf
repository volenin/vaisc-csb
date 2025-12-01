terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      # version = "3.84.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }

  # Backend configuration for state file
  # Option 1: Local backend (default)
  # To use a custom local path, run: terraform init -backend-config="path=./custom-terraform.tfstate"
  backend "local" {
    path = "terraform.tfstate"
  }

  # Option 2: GCS backend (uncomment to use)
  # To use GCS backend, comment out the local backend above and uncomment this:
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "terraform/state"
  # }
}
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone

  # The Google provider automatically retries 409 errors
  # Increase timeout to allow more time for retries and eventual consistency
  request_timeout = "120s"
}