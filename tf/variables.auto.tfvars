gcp_project_id = "artilekt-vaisc-csb"
gcp_region    = "us-central1"
gcp_zone      = "us-central1-a"

enable_apis = [
  "bigquery.googleapis.com",
  "storage.googleapis.com",
  "retail.googleapis.com",
  "run.googleapis.com",
  "serviceusage.googleapis.com",
  "workflows.googleapis.com",
  "batch.googleapis.com",
  "cloudscheduler.googleapis.com",
  "logging.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "bigqueryunified.googleapis.com",
  "iam.googleapis.com",
  "cloudaicompanion.googleapis.com",
  "notebooks.googleapis.com",
  "aiplatform.googleapis.com",
  "compute.googleapis.com",
  "dataform.googleapis.com",
  "secretmanager.googleapis.com",
]

scripts_bucket     = "artilekt-vaisc-csb_scripts"
scripts_path       = "labs"
scripts_extensions = {
  sh = ["/bin/bash"]
  py = ["python3"]
}
scripts_cr_image   = "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
scripts_cr_timeout = 1200
