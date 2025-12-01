# VAISC-CSB Terraform Configuration

## Quick Start

### Option 1: Use Existing Project (Fastest)

```bash
# Set your project
gcloud config set project your-project-id

# Initialize and deploy
./init.sh
terraform plan
terraform apply
```

### Option 2: Create New Project

```bash
# 1. Update init.sh with your FOLDER_ID and BILLING_ACCOUNT_ID
vim init.sh

# 2. Create project and initialize
./init.sh my-new-project-id

# 3. Deploy
terraform plan
terraform apply
```

## Documentation

- **[INIT_SCRIPT_GUIDE.md](INIT_SCRIPT_GUIDE.md)** - Complete guide for init.sh script
- **[INIT_EXAMPLES.md](INIT_EXAMPLES.md)** - Usage examples and workflows
- **[BACKEND_CONFIG.md](BACKEND_CONFIG.md)** - Detailed backend configuration
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick command reference

## What Gets Created

This Terraform configuration creates:

- **BigQuery Datasets:**
  - `retail` - Product catalog data
  - `merchant_center` - Merchant data

- **BigQuery Tables:**
  - `retail.products` - Retail product catalog
  - `retail.products_tmpl` - Product template with schema
  - `merchant_center.products` - Merchant product data

- **Cloud Storage:**
  - `{project-id}-retail` - Retail data bucket

- **Cloud Run Jobs:** (5 jobs for data processing)
  - `import-products-from-bq`
  - `import-products-from-gcs`
  - `import-user-events-from-gcs`
  - `generate-user-events`
  - `run-search`

- **Cloud Scheduler Jobs:** (5 scheduled jobs)
  - `scheduler-import-products-from-bq`
  - `scheduler-import-products-from-gcs`
  - `scheduler-import-user-events-from-gcs`
  - `scheduler-generate-user-events`
  - `scheduler-run-search`

- **Service Accounts:**
  - `sa-script-job` - For Cloud Run job execution
  - `sa-cr-runner` - For Cloud Scheduler triggers

- **IAM Bindings:**
  - Editor role for script job service account
  - Run invoker role for scheduler service account

- **Enabled APIs:** (18 GCP APIs)
  - Retail API, BigQuery, Cloud Run, Cloud Scheduler, and more

## File Structure

```
tf/
├── init.sh                          # Project initialization script
├── main.tf                          # BigQuery and storage resources
├── providers.tf                     # Provider and backend config
├── variables.tf                     # Variable definitions
├── variables.auto.tfvars            # Auto-generated project variables
├── scheduler.tf                     # Cloud Scheduler jobs
├── script_runner.tf                 # Cloud Run jobs
├── workflows.tf                     # Workflow definitions
├── backend.tfvars                   # Backend configuration template
├── states/                          # Project-specific state files
│   ├── <project-id>.tfstate
│   └── <project-id>-backend.tfvars
└── schemas/                         # BigQuery schemas
    └── retail_products_schema.json
```

## Common Commands

```bash
# Initialize (default project, default state)
./init.sh

# Initialize (specific project, custom state)
./init.sh my-project-id

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy resources
terraform destroy

# Show current state
terraform show

# List resources
terraform state list
```

## Environment Variables

Key variables (auto-set by init.sh):

- `gcp_project_id` - GCP project ID
- `gcp_region` - Default: us-central1
- `gcp_zone` - Default: us-central1-a
- `scripts_bucket` - Bucket containing initialization scripts

## Prerequisites

1. **gcloud CLI** installed and authenticated
2. **Terraform** v1.0+ installed
3. **Required GCP permissions:**
   - Project Creator (for new projects)
   - Editor or Owner (for existing projects)
   - Billing Account User (to link billing)

## Troubleshooting

### Issue: Project already exists (409 error)

If you get 409 errors, it means resources already exist. Options:

1. Import existing resources:
   ```bash
   terraform import google_project.project your-project-id
   ```

2. Or destroy and recreate:
   ```bash
   terraform destroy
   terraform apply
   ```

### Issue: Scheduler jobs naming conflict

Fixed in current version. Scheduler jobs now use `scheduler-` prefix to avoid conflicts with Cloud Run job names.

### Issue: Permission denied

Ensure you have proper IAM roles:
```bash
gcloud projects add-iam-policy-binding PROJECT_ID \
  --member="user:your-email@domain.com" \
  --role="roles/editor"
```

## Support

For issues or questions:
1. Check the documentation files in this directory
2. Review Terraform plan output carefully
3. Verify GCP permissions and quotas
4. Check GCP console for resource status

## License

This configuration is part of the VAISC training materials.
