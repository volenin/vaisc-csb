# Backend configuration for local state file
# Usage: terraform init -backend-config=backend.tfvars -reconfigure

# Specify custom path for local state file
path = "terraform.tfstate"

# Example custom paths:
# path = "states/dev.tfstate"
# path = "states/prod.tfstate"
# path = "../terraform-states/vaisc-csb.tfstate"
