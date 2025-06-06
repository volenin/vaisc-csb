# resource "google_workflows_workflow" "import_jobs_trigger" {
#   name     = "import-jobs-trigger"
#   region   = var.gcp_region
#   project  = var.gcp_project_id

#   description = "Triggers import-* Cloud Run jobs when Retail APIs are enabled and user agreements are accepted."

#   source_contents = <<-EOT
#     main:
#       steps:
#       - check_retail_api:
#           call: http.get
#           args:
#             url: https://serviceusage.googleapis.com/v1/projects/${project}/services/retail.googleapis.com
#             auth:
#               type: OAuth2
#           result: retail_api_status
#       - check_user_agreement:
#           call: http.get
#           args:
#             url: https://retail.googleapis.com/v2/projects/${project}/userEvent/UserAgreement
#             auth:
#               type: OAuth2
#           result: agreement_status
#       - condition:
#           switch:
#             - condition: ${retail_api_status.body.state == "ENABLED" && agreement_status.body.accepted == true}
#               next: trigger_import_jobs
#             - condition: true
#               next: end
#       - trigger_import_jobs:
#           call: googleapis.run.v2.projects.locations.jobs.run
#           args:
#             project: ${project}
#             location: ${region}
#             job: import-products-from-bq
#           result: import_job_result
#       - end:
#           return: "Workflow completed."
#   EOT

#   depends_on = [google_project_service.enabled_apis]
# }