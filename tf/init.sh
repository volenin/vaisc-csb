#!/bin/bash
# init.sh - Initialize Terraform with project-specific state file
# Usage: ./init.sh [project-id]
#
# If no project-id is provided, uses the current gcloud default project.
# State files are always stored in: states/<project-id>.tfstate

set -e

# ============================================================================
# Configuration
# ============================================================================

# Static folder ID - Update this with your actual folder ID
FOLDER_ID="80872459368"

# Billing account ID - Required for project creation
BILLING_ACCOUNT_ID="018D6E-19EDFA-DBBF91"

# State files directory
STATE_DIR="states"

# ============================================================================
# Colors for output
# ============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# Helper Functions
# ============================================================================

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# ============================================================================
# Get Project ID
# ============================================================================

if [ -z "$1" ]; then
    # No project ID provided - use current gcloud project
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

    if [ -z "$PROJECT_ID" ]; then
        error "No project ID provided and no default project set in gcloud config.\nUsage: $0 [project-id]\n\nSet default project with: gcloud config set project PROJECT_ID"
    fi

    info "Using current gcloud default project: $PROJECT_ID"
else
    PROJECT_ID="$1"
    info "Using provided project ID: $PROJECT_ID"
fi

# Validate project ID format (lowercase letters, numbers, hyphens, 6-30 chars)
if ! [[ "$PROJECT_ID" =~ ^[a-z][-a-z0-9]{4,28}[a-z0-9]$ ]]; then
    error "Invalid project ID format.\nMust be 6-30 characters, start with lowercase letter,\nand contain only lowercase letters, numbers, and hyphens."
fi

# ============================================================================
# Check if project exists and is active
# ============================================================================

info "Checking if project '$PROJECT_ID' exists and is active..."

# Get lifecycle state (returns empty if project doesn't exist at all)
LIFECYCLE_STATE=$(gcloud projects describe "$PROJECT_ID" --format="value(lifecycleState)" 2>/dev/null || echo "")

if [ -z "$LIFECYCLE_STATE" ]; then
    # Project doesn't exist at all
    warning "Project '$PROJECT_ID' does not exist"
    PROJECT_STATUS="NOT_FOUND"
elif [ "$LIFECYCLE_STATE" = "ACTIVE" ]; then
    success "Project '$PROJECT_ID' exists and is active"
    PROJECT_STATUS="ACTIVE"
elif [ "$LIFECYCLE_STATE" = "DELETE_REQUESTED" ]; then
    warning "Project '$PROJECT_ID' is pending deletion (DELETE_REQUESTED)"
    PROJECT_STATUS="DELETE_REQUESTED"
else
    warning "Project '$PROJECT_ID' has unexpected lifecycle state: $LIFECYCLE_STATE"
    PROJECT_STATUS="$LIFECYCLE_STATE"
fi

# Handle project based on status
case "$PROJECT_STATUS" in
    "ACTIVE")
        info "Using existing active project '$PROJECT_ID'"
        ;;
    "DELETE_REQUESTED")
        info "Restoring project '$PROJECT_ID' from pending deletion..."
        if ! gcloud projects undelete "$PROJECT_ID"; then
            error "Failed to restore project '$PROJECT_ID'. It may have been deleted too long ago."
        fi
        success "Project '$PROJECT_ID' restored successfully"

        # Wait for project to be fully restored
        info "Waiting for project restoration to complete..."
        sleep 5

        # Verify project is now active
        LIFECYCLE_STATE=$(gcloud projects describe "$PROJECT_ID" --format="value(lifecycleState)" 2>/dev/null || echo "")
        if [ "$LIFECYCLE_STATE" != "ACTIVE" ]; then
            error "Project restoration failed. Current state: $LIFECYCLE_STATE"
        fi
        success "Project '$PROJECT_ID' is now active"
        ;;
    "NOT_FOUND")
        info "Creating new project '$PROJECT_ID'..."

        # Check if billing account is configured
        if [ -z "$BILLING_ACCOUNT_ID" ]; then
            error "BILLING_ACCOUNT_ID is not set in the script.\nPlease update init.sh with your billing account ID."
        fi

        # Create project under folder
        if ! gcloud projects create "$PROJECT_ID" \
            --folder="$FOLDER_ID" \
            --name="$PROJECT_ID" \
            --set-as-default; then
            error "Failed to create project"
        fi

        success "Project '$PROJECT_ID' created successfully"

        # Link billing account
        info "Linking billing account..."
        if ! gcloud billing projects link "$PROJECT_ID" \
            --billing-account="$BILLING_ACCOUNT_ID"; then
            warning "Failed to link billing account. You may need to do this manually."
        else
            success "Billing account linked successfully"
        fi

        # Wait a bit for the project to be fully initialized
        info "Waiting for project initialization..."
        sleep 5
        ;;
    *)
        error "Cannot proceed with project in state: $PROJECT_STATUS"
        ;;
esac

# ============================================================================
# Set gcloud default project
# ============================================================================

info "Setting gcloud default project to '$PROJECT_ID'..."
gcloud config set project "$PROJECT_ID" --quiet

# ============================================================================
# Create state directory if it doesn't exist
# ============================================================================

if [ ! -d "$STATE_DIR" ]; then
    info "Creating state directory: $STATE_DIR"
    mkdir -p "$STATE_DIR"
fi

# ============================================================================
# Prepare Terraform backend configuration
# ============================================================================

STATE_FILE="$STATE_DIR/${PROJECT_ID}.tfstate"
BACKEND_CONFIG_FILE="${STATE_DIR}/${PROJECT_ID}-backend.tfvars"

info "State file will be: $STATE_FILE"

# Create project-specific backend config file
cat > "$BACKEND_CONFIG_FILE" <<EOF
# Backend configuration for project: $PROJECT_ID
# Auto-generated by init.sh on $(date)
path = "$STATE_FILE"
EOF

success "Created backend configuration: $BACKEND_CONFIG_FILE"

# ============================================================================
# Update variables.auto.tfvars with project ID
# ============================================================================

info "Updating gcp_project_id in variables.auto.tfvars..."

if [ -f "variables.auto.tfvars" ]; then
    # File exists - update only the gcp_project_id line

    # Check if gcp_project_id line exists
    if grep -q "^gcp_project_id" "variables.auto.tfvars"; then
        # Update existing gcp_project_id line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s/^gcp_project_id[[:space:]]*=.*/gcp_project_id = \"$PROJECT_ID\"/" variables.auto.tfvars
        else
            # Linux
            sed -i "s/^gcp_project_id[[:space:]]*=.*/gcp_project_id = \"$PROJECT_ID\"/" variables.auto.tfvars
        fi
        success "Updated gcp_project_id to '$PROJECT_ID' in variables.auto.tfvars"
    else
        # gcp_project_id doesn't exist - add it at the top
        echo "gcp_project_id = \"$PROJECT_ID\"" | cat - variables.auto.tfvars > variables.auto.tfvars.tmp
        mv variables.auto.tfvars.tmp variables.auto.tfvars
        success "Added gcp_project_id = '$PROJECT_ID' to variables.auto.tfvars"
    fi
else
    # File doesn't exist - create it with just gcp_project_id
    cat > "variables.auto.tfvars" <<EOF
gcp_project_id = "$PROJECT_ID"
EOF
    success "Created variables.auto.tfvars with gcp_project_id = '$PROJECT_ID'"
fi

# ============================================================================
# Initialize Terraform
# ============================================================================

info "Initializing Terraform with backend config..."

# Use -reconfigure to reconfigure backend without prompting
# Use -migrate-state=false to start with blank state (no migration prompt)
if terraform init -backend-config="$BACKEND_CONFIG_FILE" -reconfigure -migrate-state=false; then
    success "Terraform initialized successfully"
else
    error "Terraform initialization failed"
fi

# ============================================================================
# Display summary
# ============================================================================

echo ""
echo "========================================================================="
success "Initialization Complete!"
echo "========================================================================="
echo ""
echo "  Project ID:       $PROJECT_ID"
echo "  State File:       $STATE_FILE"
echo "  Backend Config:   $BACKEND_CONFIG_FILE"
echo ""
echo "Next steps:"
echo "  1. Review configuration: terraform plan"
echo "  2. Deploy resources:     terraform apply"
echo ""
echo "========================================================================="
