resource "google_storage_bucket" "scripts" {
  # project       = var.gcp_project_id 
  name          = "${var.gcp_project_id}_scripts"
  location      = var.gcp_region
  force_destroy = true
  uniform_bucket_level_access = true
}

# Creating GCS bucket
resource "google_storage_bucket" "retail_bucket" {
  name          = "${var.gcp_project_id}_retail"
  location      = "US"
  depends_on = [google_project_service.enabled_apis]
}


# resource "null_resource" "copy_scripts" {
#   depends_on = [google_storage_bucket.scripts]

#   provisioner "local-exec" {
#     # Note: This is a placeholder for copying a single file using curl and GCS JSON API.
#     # For recursive copy, a script iterating over objects is required.
#     command = <<EOT
# ACCESS_TOKEN=$(gcloud auth print-access-token)
# curl -X POST -H "Authorization: Bearer $ACCESS_TOKEN" \
#   -H "Content-Type: application/json" \
#   "https://storage.googleapis.com/storage/v1/b/${var.scripts_bucket}/o/${FILE_TO_COPY}/copyTo/b/${google_storage_bucket.scripts.name}/o/${FILE_TO_COPY}"
# EOT
#   }
# }