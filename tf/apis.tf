resource "google_project_service" "enabled_apis" {
  for_each           = toset(var.enable_apis)
  project            = var.gcp_project_id
  service            = each.value
  disable_on_destroy = false
}

