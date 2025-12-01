# resource "google_cloud_scheduler_job" "run_search_every_5min" {
#   name             = "run-search-every-5min"
#   description      = "Trigger Cloud Run job run-search every 5 minutes"
#   schedule         = "*/5 * * * *"
#   time_zone        = "Etc/UTC"
#   attempt_deadline = "1800"

#   http_target {
#     http_method = "POST"
#     uri         = google_cloud_run_service.run_search.status[0].url
#     oidc_token {
#       service_account_email = var.scheduler_service_account_email
#     }
#   }
# }


data "google_storage_bucket_objects" "scheduler_csvs" {
  bucket = var.scripts_bucket
  prefix = "scheduler"
  match_glob = "**/*.csv"
}

# Read each CSV file's content using google_storage_bucket_object_content
data "google_storage_bucket_object_content" "csv_files" {
  for_each = toset(data.google_storage_bucket_objects.scheduler_csvs.bucket_objects[*].name)
  bucket   = var.scripts_bucket
  name     = each.value
}

# Parse CSV content and create a map for each job
locals {
  _scheduler_jobs = flatten([
    for csv in data.google_storage_bucket_object_content.csv_files :
      [ for csv_row in csvdecode(csv.content) :
          merge(
            csv_row,
            {
              cr_name = substr(
                trim(
                  replace(
                    lower(replace(csv_row["script"], "/.(${join("|", keys(var.scripts_extensions))})$/", "")),
                    "_",
                    "-"
                  ),
                  "-"
                ),
                0,
                63
              )
              sha512 = csv.content_hexsha512
              csv_file = csv.name
            }
          )
      ]
  ])
  scheduler_jobs = [ for job in local._scheduler_jobs :
    { for k, v in job : trimspace(k) => trimspace(v) }]

  # Create indexed list with order preserved for sequential dependencies
  scheduler_jobs_ordered = [for idx, job in local.scheduler_jobs : merge(job, { index = idx })]

  # Create map keyed by cr_name for the resource for_each
  scheduler_jobs_map = {
    for job in local.scheduler_jobs_ordered :
    job.cr_name => job if contains(keys(local.script_jobs), job.cr_name)
  }
}

resource "google_service_account" "sa_cr_runner" {
  account_id   = "sa-cr-runner"
  display_name = "Cloud Run Job Scheduler Runner"
}

# Grant Cloud Run Invoker role to the service account for all jobs
resource "google_project_iam_member" "sa_cr_runner_invoker" {
  project = var.gcp_project_id
  role    = "roles/run.invoker"
  member  = google_service_account.sa_cr_runner.member
}

# Note: terraform_data cannot create a true dependency chain within for_each
# The Google provider already has built-in retry logic for 409 errors
# Combined with increased timeout, this should handle most cases

resource "google_cloud_scheduler_job" "script_scheduler" {
  for_each = local.scheduler_jobs_map
  # Job name without prefix - Cloud Run and Cloud Scheduler are in different namespaces
  name             = each.value.cr_name
  project          = var.gcp_project_id
  region           = var.gcp_region
  description      = "Trigger Cloud Run job ${each.value.script} as defined in scheduler CSV [${each.value.csv_file}] (md5sum: ${md5(each.value.sha512)})"
  schedule         = each.value.schedule
  time_zone        = "Etc/UTC"
  attempt_deadline = each.value.timeout

  retry_config {
    retry_count = 0
    # min_backoff_duration = "10s"
    # max_backoff_duration = "60s"
    max_retry_duration   = "0s"
  }

  http_target {
    http_method = "POST"
    uri         = local.script_jobs[each.value.cr_name].uri
    # headers = {
    #   "Content-Type" = "application/json"
    # }
    oauth_token {
      service_account_email = google_service_account.sa_cr_runner.email
    }
  }

  depends_on = [
    google_project_service.enabled_apis["cloudscheduler.googleapis.com"],
    google_cloud_run_v2_job.script_jobs
  ]

  lifecycle {
    create_before_destroy = false
  }

  # Add timeouts to handle API rate limiting
  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

}