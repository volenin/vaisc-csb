data "google_storage_bucket_objects" "scripts" {
  bucket = var.scripts_bucket
  prefix = var.scripts_path
  match_glob = "**/{*${join(",*", [for ext in keys(var.scripts_extensions) : ".${ext}"] )}}"

}

locals {
obj_name = "generate_user_events" # Example object name, replace with actual logic if needed
  # Filter objects to include only those with specified extensions and then extract script details
  script_files = [
    for obj_name in data.google_storage_bucket_objects.scripts.bucket_objects[*].name :
    # Check if the object name ends with any of the specified extensions
    
    # Construct an object with script details
    {
      full_path      = obj_name                                           # e.g., "path/to/your/script.sh"
      filename       = basename(obj_name)                                 # e.g., "script.sh"
      name_no_ext    = replace(basename(obj_name), "/.(${join("|", keys(var.scripts_extensions))})$/", "") # e.g., "script"
      extension      = lower(element(split(".", basename(obj_name)), length(split(".", basename(obj_name))) - 1)) # e.g., "sh"
      gcs_source_uri = "gs://${var.scripts_bucket}/${obj_name}"
      cr_name        = substr(
        trim(
          replace(
            lower(replace(basename(obj_name), "/.(${join("|", keys(var.scripts_extensions))})$/", "")),
            "_",
            "-"
          ),
          "-"
        ),
        0,
        63
      )
    } if contains(keys(var.scripts_extensions), lower(element(split(".", basename(obj_name)), length(split(".", basename(obj_name))) - 1)))
  ]
}

resource "google_service_account" "sa_script_job" {
  account_id   = "sa-script-job"
  display_name = "Cloud Run Script Job Runner"
}

resource "google_project_iam_member" "sa_script_job_editor" {
  project = var.gcp_project_id
  role    = "roles/editor"
  member  = google_service_account.sa_script_job.member
}

resource "google_cloud_run_v2_job" "script_jobs" {
  for_each = { for script in local.script_files : script.cr_name => script }

  name = each.value.cr_name
  location = var.gcp_region
  project  = var.gcp_project_id

  template {
    template {
      service_account = google_service_account.sa_script_job.email
      containers {
        image   = var.scripts_cr_image
        command = var.scripts_extensions[each.value.extension]
        args    = ["/mnt/scripts-bucket/${each.value.full_path}"]
        working_dir = "/mnt/scripts-bucket/${dirname(each.value.full_path)}"
        volume_mounts {
          name       = "scripts-bucket-mount"
          mount_path = "/mnt/scripts-bucket"
        }
      }
      volumes {
        name = "scripts-bucket-mount"
        gcs {
          bucket    = var.scripts_bucket
          read_only = true
        }
      }
      max_retries = 0
      timeout     = "${var.scripts_cr_timeout}s"
    }
  }
  deletion_protection = false
  depends_on = [google_project_service.enabled_apis]


}

locals {
  script_jobs = { for job in values(google_cloud_run_v2_job.script_jobs) :
    job.name => {
      name        = job.name
      location    = job.location
      project     = job.project
      sa          = google_service_account.sa_script_job.email
      uri         = "https://${job.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${job.project}/jobs/${job.name}:run"
    }
  }
}
