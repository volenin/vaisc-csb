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

resource "google_cloud_scheduler_job" "script_scheduler" {
  for_each = { for job in local.scheduler_jobs : job.cr_name => job if contains(keys(local.script_jobs), job.cr_name) }
  # Ensure the job name is unique and valid
  name             = each.value.cr_name
  project          = var.gcp_project_id
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

}