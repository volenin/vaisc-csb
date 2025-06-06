variable "gcp_project_id" {
  type        = string
  description = "The GCP Project ID to apply this config to."
}

variable "gcp_region" {
  type        = string
  description = "The GCP region to apply this config to."
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone to apply this config to."
}

variable "enable_apis" {
  description = "List of APIs to enable for this project."
  type        = list(string)
}

variable "scripts_bucket" {
  description = "The GCS bucket name where scripts are located."
  type        = string
}

variable "scripts_path" {
  description = "The path prefix (folder) within the GCS bucket for scripts. Can be empty for bucket root. Should not start with /."
  type        = string
}

variable "scripts_extensions" {
  description = "A list of script file extensions to look for (e.g., [\"sh\", \"py\"])."
  type        = map(list(string))
}

variable "scripts_cr_image" {
  description = "The container image to use for the Cloud Run jobs."
  type        = string
}

variable "scripts_cr_timeout" {
  description = "The timeout for the Cloud Run jobs in seconds."
  type        = number
}