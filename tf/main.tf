# Creating BQ dataset
resource "google_bigquery_dataset" "dataset1" {
  dataset_id                  = "retail"
  depends_on = [google_project_service.enabled_apis]
}

resource "google_bigquery_dataset" "dataset2" {
  dataset_id                  = "merchant_center"
  depends_on = [google_project_service.enabled_apis]
}

# Creating GCS bucket
resource "google_storage_bucket" "retail_bucket" {
  name          = "${var.gcp_project_id}-retail"
  location      = "US"
  depends_on = [google_project_service.enabled_apis]
}

# Creating BQ tables
resource "google_bigquery_table" "retail_products_table" {
  deletion_protection = false
  dataset_id = google_bigquery_dataset.dataset1.dataset_id
  table_id   = "products"
  depends_on = [google_project_service.enabled_apis]
}

resource "google_bigquery_table" "retail_products_table_tmpl" {
  deletion_protection = false
  dataset_id = google_bigquery_dataset.dataset1.dataset_id
  table_id   = "products_tmpl"
  schema = file("${path.module}/schemas/retail_products_schema.json")
  depends_on = [google_project_service.enabled_apis]
}

resource "google_bigquery_table" "merchant_products_table" {
  deletion_protection = false
  dataset_id = google_bigquery_dataset.dataset2.dataset_id
  table_id   = "products"
  depends_on = [google_project_service.enabled_apis]
}


resource "random_id" "job_suffix" {
  byte_length = 4
}

# Load Job
resource "google_bigquery_job" "job1" {
  job_id = "load_retail_products_${random_id.job_suffix.hex}"

  load {
    source_uris = [
      "gs://sureskills-ql/partner-workshops/product-discovery/retail_products.avro"
    ]
    destination_table {
      project_id = var.gcp_project_id
      dataset_id = google_bigquery_dataset.dataset1.dataset_id
      table_id   = google_bigquery_table.retail_products_table.table_id
    }
    write_disposition = "WRITE_APPEND"
    source_format = "AVRO"
  }
  depends_on = [google_project_service.enabled_apis]
}

resource "google_bigquery_job" "job2" {
  job_id     = "load_merchant_products_${random_id.job_suffix.hex}"

  load {
    source_uris = [
      "gs://sureskills-ql/partner-workshops/product-discovery/mc_products.avro"
    ]
    destination_table {
      project_id = var.gcp_project_id
      dataset_id = google_bigquery_dataset.dataset2.dataset_id
      table_id   = google_bigquery_table.merchant_products_table.table_id
    }
    write_disposition = "WRITE_APPEND"
    source_format = "AVRO"
  }
  depends_on = [google_project_service.enabled_apis]
}

# # Cloud Run Job to run startup.sh logic
# resource "google_cloud_run_v2_job" "retail_events_setup" {
#   name     = "retail-events-setup-job"
#   location = var.gcp_region

#   template {
#     template {
#       containers {
#         image = "gcr.io/google.com/cloudsdktool/cloud-sdk:slim"
#         command = ["/bin/bash", "-c"]
#         args = [<<-EOT
#           # Copy source files from the mounted public GCS bucket to the container's local filesystem
#           cp /mnt/src-bucket/partner-workshops/product-discovery/retail_events.json .
#           cp /mnt/src-bucket/partner-workshops/product-discovery/create_recent_events.py .
#           # Run the python script, which creates recent_retail_events.json in the current directory
#           python3 create_recent_events.py
#           sleep 10
#           # Copy the generated file to the mounted GCS bucket
#           cp recent_retail_events.json /mnt/dest-bucket/recent_retail_events.json
#         EOT
#         ]
#         volume_mounts {
#           name       = "dest-bucket-mount"
#           mount_path = "/mnt/dest-bucket"
#         }
#         volume_mounts {
#           name       = "src-bucket-mount"
#           mount_path = "/mnt/src-bucket"
#         }
#       }
#       volumes {
#         name = "dest-bucket-mount"
#         gcs {
#           bucket    = google_storage_bucket.retail_bucket.name
#           read_only = false # Needs to be false to write the output file
#         }
#       }
#       volumes {
#         name = "src-bucket-mount"
#         gcs {
#           bucket    = "sureskills-ql" # Public bucket
#           read_only = true
#         }
#       }
#       max_retries = 1
#       timeout     = "600s"
#     }
#   }
#   depends_on = [google_project_service.enabled_apis]
# }

resource "google_project_service" "enabled_apis" {
  for_each           = toset(var.enable_apis)
  project            = var.gcp_project_id
  service            = each.value
  disable_on_destroy = false
}

