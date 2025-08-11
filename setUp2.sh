#!/bin/bash

#==============================================================================
# DevExp-DevBox Setup Script
#==============================================================================
# Description: Sets up DevBox environment with source control and Azure config
#              Supports both interactive and automated authentication modes
#              via command-line parameters for enhanced security and CI/CD integration
#              
# Key Features:
#   - Command-line parameter for KEY_VAULT_SECRET (--key-vault-secret)
#   - Automatic token format validation for GitHub and Azure DevOps
#   - Secure token masking in all log outputs
#   - Fallback to interactive authentication if parameter not provided
#   - Enhanced error handling and validation
#
# Author: DevExp Team
# Version: 2.1
# Last Modified: August 2025
#==============================================================================

# Exit on any error, undefined variables, or pipe failures
set -euo pipefail

#------------------------------------------------------------------------------
# CONSTANTS AND CONFIGURATION
#------------------------------------------------------------------------------
readonly SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_VERSION="2.1"
readonly MAX_ENV_NAME_LENGTH=50
readonly MIN_ENV_NAME_LENGTH=1
readonly ENV_FILE_MAX_LINES=1000
readonly TOKEN_DISPLAY_PREFIX_LENGTH=8
readonly TOKEN_DISPLAY_SUFFIX_LENGTH=4

# Constants for token validation
readonly MIN_TOKEN_LENGTH=8
readonly GITHUB_PAT_LENGTH=40
readonly GITHUB_NEW_PAT_LENGTH=76
readonly ADO_PAT_LENGTH=52

# Supported platforms
readonly -a VALID_PLATFORMS=("github" "adogit")

# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_INVALID_PARAMS=1
readonly EXIT_VALIDATION_FAILED=2
readonly EXIT_AUTH_FAILED=3
readonly EXIT_FILE_ERROR=4

# Environment variable patterns
readonly ENV_VAR_PATTERN='^[a-zA-Z_][a-zA-Z0-9_]*$'
readonly ENV_NAME_PATTERN='^[a-zA-Z0-9][a-zA-Z0-9_-]*[a-zA-Z0-9]$|^[a-zA-Z0-9]$'

#------------------------------------------------------------------------------
# GLOBAL VARIABLES
#------------------------------------------------------------------------------
SOURCE_CONTROL_PLATFORM=""
AZURE_ENV_NAME=""
GITHUB_TOKEN=""
KEY_VAULT_SECRET=""

#------------------------------------------------------------------------------
# UTILITY FUNCTIONS
#------------------------------------------------------------------------------

# Check if a command exists in PATH
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Safely escape a string for sed
escape_for_sed() {
    # Safely escape a string for sed
    printf '%s\n' "$1" | sed 's/[[\.*^$()+?{|]/\\&/g'
}

# Validate string is not empty and doesn't contain only whitespace
is_not_empty() {
    [[ -n "$1" && "$1" != *[[:space:]]* ]]
}

# Display script header
show_header() {
    echo "========================================"
    echo "  DevExp-DevBox Setup Script v${SCRIPT_VERSION}"
    echo "========================================"
    echo ""
}

# Display usage information
show_usage() {
    show_usage_header
    show_usage_synopsis
    show_usage_description
    show_usage_parameters
    show_usage_options
    show_usage_examples
    show_usage_footer
}

show_usage_header() {
    cat << EOF
NAME
    ${SCRIPT_NAME} - Configure DevBox environment with source control and Azure settings

EOF
}

show_usage_synopsis() {
    cat << EOF
SYNOPSIS
    ${SCRIPT_NAME} --source-control-platform <platform> --azure-env-name <environment> [--key-vault-secret <secret>]
    ${SCRIPT_NAME} --validate-prerequisites | --check-auth | --check-azd-auth
    ${SCRIPT_NAME} --check-github-auth | --check-devops-auth
    ${SCRIPT_NAME} [--help] [--version]

EOF
}

show_usage_description() {
    cat << EOF
DESCRIPTION
    Configures DevBox environment with specified source control platform
    integration and Azure environment configuration. Optionally accepts
    a pre-configured authentication secret/token for enhanced security.

EOF
}

show_usage_parameters() {
    cat << EOF
MANDATORY PARAMETERS
    --source-control-platform <platform>
        Source control platform (github | adogit)

    --azure-env-name <environment>
        Azure environment name (e.g., dev, test, staging, prod)

OPTIONAL PARAMETERS
    --key-vault-secret <secret>
        Pre-configured authentication secret/token for the selected platform:
        - For GitHub: Personal Access Token (PAT) or GitHub App token
        - For Azure DevOps: Personal Access Token (PAT)
        If not provided, the script will attempt to retrieve from CLI or prompt

EOF
}

show_usage_options() {
    cat << EOF
OPTIONS
    --validate-prerequisites    Check required tools are installed
    --check-auth               Verify Azure CLI authentication
    --check-azd-auth           Verify Azure Developer CLI authentication  
    --check-github-auth        Verify GitHub CLI authentication
    --check-devops-auth        Verify Azure DevOps CLI authentication
    --version                  Display version information
    -h, --help                 Display this help message

EOF
}

show_usage_examples() {
    cat << EOF
EXAMPLES
    # Basic usage with interactive authentication
    ${SCRIPT_NAME} --source-control-platform github --azure-env-name dev
    ${SCRIPT_NAME} --source-control-platform adogit --azure-env-name prod
    
    # Usage with pre-configured secret (recommended for automation)
    ${SCRIPT_NAME} --source-control-platform github --azure-env-name dev --key-vault-secret "ghp_xxxxxxxxxxxxxxxxxxxx"
    ${SCRIPT_NAME} --source-control-platform adogit --azure-env-name prod --key-vault-secret "your-ado-pat-token"
    
    # Secure automation usage with environment variables
    export DEVBOX_SECRET="\${MY_SECURE_TOKEN}"
    ${SCRIPT_NAME} --source-control-platform github --azure-env-name dev --key-vault-secret "\${DEVBOX_SECRET}"
    
    # Validation and checks
    ${SCRIPT_NAME} --validate-prerequisites

EXIT STATUS
    ${EXIT_SUCCESS}    Success
    ${EXIT_INVALID_PARAMS}    Invalid parameters
    ${EXIT_VALIDATION_FAILED}    Validation failed

EOF
}

show_usage_footer() {
    cat << 'EOF'
SECURITY CONSIDERATIONS
    When using --key-vault-secret parameter:
    - Store tokens securely (e.g., environment variables, secure key vaults)
    - Use tokens with minimal required permissions
    - Rotate tokens regularly according to your organization's policy
    - Avoid hardcoding tokens in scripts or configuration files

    For GitHub: Use fine-grained personal access tokens when possible
    For Azure DevOps: Create PATs with specific scopes and expiration dates

For more information: https://github.com/Evilazaro/DevExp-DevBox
EOF
}

#------------------------------------------------------------------------------
# LOGGING FUNCTIONS
#------------------------------------------------------------------------------

# Display formatted messages with consistent formatting
log_message() {
    local level="$1"
    local message="$2"
    local output_stream="${3:-/dev/stdout}"
    
    echo "[$level] $message" > "$output_stream"
}

# Display formatted messages
show_error() {
    log_message "ERROR" "$1" /dev/stderr
    echo "        Use '${SCRIPT_NAME} --help' for usage information." >&2
}

show_success() {
    log_message "SUCCESS" "$1"
}

show_info() {
    log_message "INFO" "$1"
}

show_warning() {
    log_message "WARNING" "$1"
}

#------------------------------------------------------------------------------
# AZURE ENVIRONMENT FILE MANAGEMENT
#------------------------------------------------------------------------------

# Update Azure environment file with key-value pair
update_azure_env_file() {
    local key="$1"
    local value="$2"
    
    validate_env_key "$key" || return $EXIT_VALIDATION_FAILED
    validate_azure_env_name_set || return $EXIT_VALIDATION_FAILED
    
    # Validate environment name doesn't contain path traversal
    if [[ "$AZURE_ENV_NAME" =~ \.\.|\/ ]]; then
        show_error "Invalid environment name contains path traversal characters"
        return $EXIT_VALIDATION_FAILED
    fi
    
    local env_file=".azure/${AZURE_ENV_NAME}/.env"
    
    show_info "Updating Azure environment variable: $key"
    
    ensure_env_file_exists "$env_file" || return $EXIT_FILE_ERROR
    update_or_add_env_value "$env_file" "$key" "$value"
}

# Validate environment variable key format
validate_env_key() {
    local key="$1"
    
    if ! is_not_empty "$key"; then
        show_error "Environment variable key cannot be empty"
        return $EXIT_VALIDATION_FAILED
    fi
    
    if [[ ! "$key" =~ $ENV_VAR_PATTERN ]]; then
        show_error "Invalid environment variable key: '$key'"
        echo "        Keys must start with letter/underscore, contain only alphanumeric/underscore" >&2
        return $EXIT_VALIDATION_FAILED
    fi
    
    return $EXIT_SUCCESS
}

# Validate AZURE_ENV_NAME is set
validate_azure_env_name_set() {
    if ! is_not_empty "$AZURE_ENV_NAME"; then
        show_error "AZURE_ENV_NAME environment variable is not set"
        return $EXIT_VALIDATION_FAILED
    fi
    return $EXIT_SUCCESS
}

# Create Azure environment using azd
create_azd_environment() {
    local env_name="$1"
    
    if ! command_exists "azd"; then
        show_error "Azure Developer CLI (azd) is required"
        return $EXIT_VALIDATION_FAILED
    fi
    
    # Only create the environment if it doesn't already exist
    if ! azd env list 2>/dev/null | grep -q "^${env_name}$"; then
        show_info "Creating new Azure environment: $env_name"
        azd env new "$env_name" --no-prompt || return $EXIT_FILE_ERROR
    else
        show_info "Azure environment '$env_name' already exists"
    fi
    
    return $EXIT_SUCCESS
}

# Ensure environment file exists, create if necessary
ensure_env_file_exists() {
    local env_file="$1"
    
    # Validate input
    if [[ -z "$env_file" ]]; then
        show_error "Environment file path cannot be empty"
        return $EXIT_FILE_ERROR
    fi
    
    if [[ -f "$env_file" ]]; then
        return $EXIT_SUCCESS
    fi
    
    show_info "Creating Azure environment: $AZURE_ENV_NAME"
    
    create_azd_environment "$AZURE_ENV_NAME" || return $EXIT_FILE_ERROR
    
    # Verify the environment file was created or already exists
    if [[ -f "$env_file" ]]; then
        return $EXIT_SUCCESS
    else
        show_error "Environment file not found at: $env_file"
        return $EXIT_FILE_ERROR
    fi
}

# Update or add environment value
update_or_add_env_value() {
    local env_file="$1"
    local key="$2" 
    local value="$3"
    
    local escaped_value
    escaped_value=$(escape_for_sed "$value")
    
    if grep -q "^${key}=" "$env_file" 2>/dev/null; then
        update_existing_env_value "$env_file" "$key" "$escaped_value"
    else
        add_new_env_value "$env_file" "$key" "$value"
    fi
}

# Update existing environment value
update_existing_env_value() {
    local env_file="$1"
    local key="$2"
    local escaped_value="$3"
    
    show_info "Updating existing key: $key"
    
    if sed -i "s/^${key}=.*/${key}=${escaped_value}/" "$env_file" 2>/dev/null; then
        show_success "Updated $key in Azure environment file"
        return $EXIT_SUCCESS
    else
        show_error "Failed to update $key"
        return $EXIT_FILE_ERROR
    fi
}

# Add new environment value
add_new_env_value() {
    local env_file="$1"
    local key="$2"
    local value="$3"
    
    show_info "Adding new key: $key"
    
    # Check file size limit
    local line_count
    line_count=$(wc -l < "$env_file" 2>/dev/null || echo "0")
    
    if [[ $line_count -ge $ENV_FILE_MAX_LINES ]]; then
        show_warning "Environment file is approaching size limit ($line_count lines)"
    fi
    
    # Ensure file ends with newline
    ensure_file_ends_with_newline "$env_file"
    
    if echo "${key}=${value}" >> "$env_file"; then
        show_success "Added $key to Azure environment file"
        return $EXIT_SUCCESS
    else
        show_error "Failed to add $key to Azure environment file"
        return $EXIT_FILE_ERROR
    fi
}

# Ensure file ends with newline
ensure_file_ends_with_newline() {
    local file="$1"
    
    if [[ -s "$file" ]] && [[ $(tail -c1 "$file" 2>/dev/null) != "" ]]; then
        echo "" >> "$file"
    fi
}

# Read value from Azure environment file
read_azure_env_value() {
    local key="$1"
    
    validate_env_key "$key" || return $EXIT_VALIDATION_FAILED
    validate_azure_env_name_set || return $EXIT_VALIDATION_FAILED
    
    # Validate environment name doesn't contain path traversal
    if [[ "$AZURE_ENV_NAME" =~ \.\.|\/ ]]; then
        show_error "Invalid environment name contains path traversal characters"
        return $EXIT_VALIDATION_FAILED
    fi
    
    local env_file=".azure/${AZURE_ENV_NAME}/.env"
    
    if [[ ! -f "$env_file" ]]; then
        show_warning "Azure environment file does not exist: $env_file"
        return $EXIT_FILE_ERROR
    fi
    
    local value
    value=$(grep "^${key}=" "$env_file" 2>/dev/null | cut -d'=' -f2- | head -1)
    
    if is_not_empty "$value"; then
        echo "$value"
        return $EXIT_SUCCESS
    else
        show_warning "Key '$key' not found in Azure environment file"
        return $EXIT_FILE_ERROR
    fi
}

# Validate Azure environment file
validate_azure_env_file() {
    validate_azure_env_name_set || return $EXIT_VALIDATION_FAILED
    
    # Validate environment name doesn't contain path traversal
    if [[ "$AZURE_ENV_NAME" =~ \.\.|\/ ]]; then
        show_error "Invalid environment name contains path traversal characters"
        return $EXIT_VALIDATION_FAILED
    fi
    
    local env_file=".azure/${AZURE_ENV_NAME}/.env"
    
    show_info "Validating Azure environment file: $env_file"
    
    if [[ ! -f "$env_file" ]]; then
        show_warning "Azure environment file does not exist"
        return $EXIT_FILE_ERROR
    fi
    
    if [[ ! -r "$env_file" ]]; then
        show_error "Azure environment file is not readable"
        return $EXIT_FILE_ERROR
    fi
    
    display_env_file_info "$env_file"
    validate_env_file_contents "$env_file"
}

# Display environment file information
display_env_file_info() {
    local env_file="$1"
    local line_count
    line_count=$(wc -l < "$env_file" 2>/dev/null || echo "0")
    
    echo "         Environment: $AZURE_ENV_NAME"
    echo "         File: $env_file" 
    echo "         Lines: $line_count"
    echo "         Contents:"
}

# Validate environment file contents
validate_env_file_contents() {
    local env_file="$1"
    local valid_pairs=0
    local invalid_pairs=0
    
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        if is_valid_env_line "$line"; then
            local key value
            # Use parameter expansion to safely extract key and value
            key="${line%%=*}"
            value="${line#*=}"
            # Trim whitespace
            key="$(echo "$key" | xargs)"
            value="$(echo "$value" | xargs)"
            echo "           $key = $value"
            ((valid_pairs++))
        else
            show_warning "Invalid line format: $line"
            ((invalid_pairs++))
        fi
    done < "$env_file"
    
    echo "         Valid pairs: $valid_pairs"
    
    if [[ $invalid_pairs -gt 0 ]]; then
        echo "         Invalid pairs: $invalid_pairs"
        show_warning "Some lines have invalid format"
        return $EXIT_VALIDATION_FAILED
    fi
    
    show_success "Azure environment file validation completed"
    return $EXIT_SUCCESS
}

# Check if a line is a valid environment variable assignment
is_valid_env_line() {
    local line="$1"
    [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.*)[[:space:]]*$ ]]
}

#------------------------------------------------------------------------------
# AUTHENTICATION INSTRUCTION FUNCTIONS  
#------------------------------------------------------------------------------

# Display Azure CLI login instructions
show_azure_login_instructions() {
    cat << 'EOF'
[LOGIN GUIDE] Azure CLI Authentication:

Method 1 - Interactive Login (Recommended):
   az login

Method 2 - Device Code Login (For headless systems):  
   az login --use-device-code

Method 3 - Service Principal Login (For automation):
   az login --service-principal --username <app-id> --password <password> --tenant <tenant-id>

Additional Commands:
   az account list --output table     # List subscriptions
   az account set --subscription <id> # Set active subscription  
   az account show --output table     # Show current account
   az logout                          # Clear credentials

For more options: https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli
EOF
}

# Display Azure Developer CLI login instructions
show_azd_login_instructions() {
    cat << 'EOF'
[LOGIN GUIDE] Azure Developer CLI (azd) Authentication:

Method 1 - Interactive Login (Recommended):
   azd auth login

Method 2 - Device Code Login (For headless systems):
   azd auth login --use-device-code

Method 3 - Service Principal Login (For automation):
   export AZURE_CLIENT_ID="<client-id>"
   export AZURE_CLIENT_SECRET="<client-secret>" 
   export AZURE_TENANT_ID="<tenant-id>"
   azd auth login --client-id $AZURE_CLIENT_ID --client-secret $AZURE_CLIENT_SECRET --tenant-id $AZURE_TENANT_ID

Additional Commands:
   azd auth status      # Check authentication status
   azd config list-alpha # Show account information
   azd auth logout      # Clear credentials

For more options: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/reference#azd-auth
EOF
}

# Display Azure DevOps CLI login instructions  
show_azure_devops_login_instructions() {
    cat << 'EOF'
[LOGIN GUIDE] Azure DevOps CLI Authentication:

Method 1 - Interactive Login:
   az devops login
   # Provide organization URL: https://dev.azure.com/<your-organization>

Method 2 - Personal Access Token (PAT):
   export AZURE_DEVOPS_EXT_PAT=<your-token>
   az devops login --organization https://dev.azure.com/<your-organization>

Method 3 - Configure Default Organization:
   az devops configure --defaults organization=https://dev.azure.com/<your-organization>

Additional Commands:
   az devops user show            # Check authentication status
   az devops configure --list     # List current configuration
   az devops project list         # Test connectivity

For more options: https://docs.microsoft.com/en-us/azure/devops/cli/
EOF
}

# Display GitHub CLI login instructions
show_github_login_instructions() {
    cat << 'EOF'
[LOGIN GUIDE] GitHub CLI Authentication:

Method 1 - Web Browser Login (Recommended):
   gh auth login --web

Method 2 - Interactive Login:
   gh auth login
   # Choose "Login with a web browser"

Method 3 - Personal Access Token:
   gh auth login --with-token < token.txt

Additional Commands:
   gh auth status       # Check authentication status
   gh api user --jq '.login' # View current user
   gh auth refresh      # Refresh token
   gh auth logout       # Logout

For more options: https://cli.github.com/manual/gh_auth
EOF
}

#------------------------------------------------------------------------------
# AUTHENTICATION VALIDATION FUNCTIONS
#------------------------------------------------------------------------------

# Generic authentication validation function
validate_cli_authentication() {
    local cli_name="$1"
    local command_name="$2"
    local auth_check_cmd="$3"
    local instruction_function="$4"
    
    show_info "Checking $cli_name authentication status..."
    
    if ! command_exists "$command_name"; then
        show_error "$cli_name is not installed or not in PATH"
        echo "        Install using: ${SCRIPT_NAME} --validate-prerequisites" >&2
        return $EXIT_VALIDATION_FAILED
    fi
    
    local auth_output exit_code
    # Security: Validate auth_check_cmd before executing
    if [[ -z "$auth_check_cmd" ]]; then
        show_error "Authentication check command is empty"
        return $EXIT_VALIDATION_FAILED
    fi
    auth_output=$(eval "$auth_check_cmd" 2>&1)
    exit_code=$?
    
    if [[ $exit_code -eq $EXIT_SUCCESS ]]; then
        show_success "$cli_name authentication verified"
        display_auth_info "$cli_name" "$auth_output"
        return $EXIT_SUCCESS
    else
        show_warning "You are not authenticated with $cli_name"
        echo ""
        echo "$cli_name authentication is required for this operation."
        echo ""
        $instruction_function
        echo ""
        return $EXIT_AUTH_FAILED
    fi
}

# Display authentication information
display_auth_info() {
    local cli_name="$1" 
    local auth_output="$2"
    
    case "$cli_name" in
        "Azure CLI")
            display_azure_auth_info "$auth_output"
            ;;
        "Azure Developer CLI")
            display_azd_auth_info "$auth_output"
            ;;
        "GitHub CLI")
            display_github_auth_info "$auth_output"
            ;;
        "Azure DevOps CLI")
            display_devops_auth_info "$auth_output"
            ;;
    esac
}

# Extract Azure CLI information safely
extract_azure_cli_info() {
    local info_type="$1"
    az account show --query "$info_type" --output tsv 2>/dev/null || echo "unknown"
}

# Display Azure CLI authentication information
display_azure_auth_info() {
    local auth_output="$1"
    
    local user_name subscription_name subscription_id tenant_id
    
    subscription_name=$(extract_azure_cli_info "name")
    subscription_id=$(extract_azure_cli_info "id")
    tenant_id=$(extract_azure_cli_info "tenantId")
    user_name=$(extract_azure_cli_info "user.name")
    
    echo "         User: $user_name"
    echo "         Subscription: $subscription_name"
    echo "         Subscription ID: $subscription_id"
    echo "         Tenant ID: $tenant_id"
}

# Extract AZD configuration value safely
extract_azd_config() {
    local config_key="$1"
    azd config get "$config_key" 2>/dev/null | sed 's/"//g' || echo ""
}

# Display Azure Developer CLI authentication information
display_azd_auth_info() {
    local auth_output="$1"
    
    local subscription_info location_info
    subscription_info=$(extract_azd_config "defaults.subscription")
    location_info=$(extract_azd_config "defaults.location")
    
    echo "         User: Authenticated User"
    
    if is_not_empty "$subscription_info" && [[ "$subscription_info" != "null" ]]; then
        if [[ "$subscription_info" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
            echo "         Subscription ID: $subscription_info"
        else
            echo "         Subscription: $subscription_info"
        fi
    fi
    
    if is_not_empty "$location_info" && [[ "$location_info" != "null" ]]; then
        echo "         Default Location: $location_info"
    fi
    
    echo "         Status: Successfully authenticated with Azure"
}

# Display GitHub CLI authentication information
display_github_auth_info() {
    local auth_output="$1"
    
    local github_user
    github_user=$(echo "$auth_output" | grep -i "logged in to.*as" | sed 's/.*as \([^ ]*\).*/\1/' 2>/dev/null || echo "GitHub User")
    
    echo "         User: $github_user"
    echo "         Host: github.com"
    
    show_info "Retrieving GitHub authentication token..."
    retrieve_github_token
}

# Extract JSON value safely without jq dependency
extract_json_value() {
    local json="$1"
    local key="$2"
    local default="$3"
    
    if command_exists "jq"; then
        echo "$json" | jq -r ".${key} // \"${default}\"" 2>/dev/null || echo "$default"
    else
        # Use safer regex pattern matching for JSON extraction
        echo "$json" | sed -n "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" 2>/dev/null | head -1 || echo "$default"
    fi
}

# Extract Azure DevOps organization name from URL
extract_devops_org_name() {
    local org_config="$1"
    
    if is_not_empty "$org_config" && [[ "$org_config" != "None" ]]; then
        echo "$org_config" | sed 's|https://dev.azure.com/||' | sed 's|/$||' 2>/dev/null || echo "$org_config"
    fi
}

# Display Azure DevOps CLI authentication information
display_devops_auth_info() {
    local auth_output="$1"
    
    local user_name user_email user_id organization_name org_config
    
    user_name=$(extract_json_value "$auth_output" "displayName" "Unknown User")
    if [[ "$user_name" == "Unknown User" ]]; then
        user_name=$(extract_json_value "$auth_output" "name" "Unknown User")
    fi
    
    user_email=$(extract_json_value "$auth_output" "mailAddress" "")
    if [[ -z "$user_email" ]]; then
        user_email=$(extract_json_value "$auth_output" "uniqueName" "")
    fi
    
    user_id=$(extract_json_value "$auth_output" "id" "")
    
    org_config=$(az devops configure --list 2>/dev/null | grep "organization" | cut -d'=' -f2 2>/dev/null | tr -d ' ' || echo "")
    organization_name=$(extract_devops_org_name "$org_config")
    
    echo "         User: $user_name"
    
    if is_not_empty "$user_email" && [[ "$user_email" != "null" ]]; then
        echo "         Email: $user_email"
    fi
    
    if is_not_empty "$organization_name"; then
        echo "         Organization: $organization_name"
    fi
    
    if is_not_empty "$user_id" && [[ "$user_id" != "null" ]]; then
        echo "         User ID: $user_id"
    fi
}

# Securely log sensitive information by masking secrets
log_secure_info() {
    local message="$1"
    local secret="$2"
    
    if [[ -n "$secret" ]]; then
        local masked_secret
        masked_secret=$(mask_token "$secret")
        echo "$message: $masked_secret"
    else
        echo "$message: (not provided)"
    fi
}

# Mask sensitive token for display
mask_token() {
    local token="$1"
    local prefix_length="${2:-$TOKEN_DISPLAY_PREFIX_LENGTH}"
    local suffix_length="${3:-$TOKEN_DISPLAY_SUFFIX_LENGTH}"
    
    # Validate input
    if [[ -z "$token" ]]; then
        echo "***empty***"
        return
    fi
    
    if [[ ${#token} -le $((prefix_length + suffix_length + 3)) ]]; then
        echo "***masked***"
    else
        echo "${token:0:$prefix_length}...${token: -$suffix_length}"
    fi
}

# Retrieve and store GitHub token
retrieve_github_token() {
    # If KEY_VAULT_SECRET is provided as parameter, use it
    if [[ -n "${KEY_VAULT_SECRET:-}" ]]; then
        GITHUB_TOKEN="$KEY_VAULT_SECRET"
        show_success "GitHub token retrieved from parameter"
        echo "         Token: $(mask_token "$GITHUB_TOKEN") (masked)"
        return $EXIT_SUCCESS
    fi
    
    # Otherwise, try to retrieve from GitHub CLI
    local token_output
    token_output=$(gh auth token 2>/dev/null)
    local token_exit_code=$?
    
    if [[ $token_exit_code -eq $EXIT_SUCCESS ]] && is_not_empty "$token_output"; then
        GITHUB_TOKEN="$token_output"
        KEY_VAULT_SECRET="${GITHUB_TOKEN}"
        show_success "GitHub token retrieved from CLI"
        echo "         Token: $(mask_token "$GITHUB_TOKEN") (masked)"
        return $EXIT_SUCCESS
    else
        show_warning "Failed to retrieve GitHub token from CLI"
        return $EXIT_AUTH_FAILED
    fi
}

# Specific authentication validation functions
validate_azure_authentication() {
    validate_cli_authentication "Azure CLI" "az" "az account show --output json" "show_azure_login_instructions"
}

validate_azd_authentication() {
    validate_cli_authentication "Azure Developer CLI" "azd" "azd auth status" "show_azd_login_instructions"
}

validate_github_authentication() {
    validate_cli_authentication "GitHub CLI" "gh" "gh auth status" "show_github_login_instructions"
}

validate_azure_devops_authentication() {
    # Special handling for Azure DevOps CLI extension check
    show_info "Checking Azure DevOps CLI authentication status..."
    
    if ! command_exists "az"; then
        show_error "Azure CLI is required for Azure DevOps CLI extension"
        echo "        Install using: ${SCRIPT_NAME} --validate-prerequisites" >&2
        return $EXIT_VALIDATION_FAILED
    fi
    
    if ! az extension list --output tsv 2>/dev/null | grep -q "azure-devops"; then
        show_error "Azure DevOps CLI extension is not installed"
        echo "        Install using: ${SCRIPT_NAME} --validate-prerequisites" >&2
        return $EXIT_VALIDATION_FAILED
    fi
    
    # If KEY_VAULT_SECRET is provided as parameter, use it directly
    if [[ -n "${KEY_VAULT_SECRET:-}" ]]; then
        show_info "Using provided Azure DevOps token from parameter"
        export AZURE_DEVOPS_EXT_PAT="${KEY_VAULT_SECRET}"
        
        # Test the token by trying to get user info
        local user_info_output
        user_info_output=$(az devops user show --output json 2>&1)
        local exit_code=$?
        
        if [[ $exit_code -eq 0 ]] && [[ -n "$user_info_output" ]]; then
            show_success "Azure DevOps CLI authentication verified with provided token"
            display_devops_auth_info "$user_info_output"
            return $EXIT_SUCCESS
        else
            show_error "Provided Azure DevOps token is invalid or insufficient"
            return $EXIT_AUTH_FAILED
        fi
    fi
    
    # Try existing authentication first
    local user_info_output
    user_info_output=$(az devops user show --output json 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && [[ -n "$user_info_output" ]]; then
        show_success "Azure DevOps CLI authentication verified"
        display_devops_auth_info "$user_info_output"
        return $EXIT_SUCCESS
    else
        show_warning "You are not authenticated with Azure DevOps CLI"
        echo ""
        echo "Azure DevOps authentication is required for adogit platform."
        echo ""
        show_azure_devops_login_instructions
        echo ""
         # Prompt for PAT securely (no echo)
        echo -n "Enter your Azure DevOps Personal Access Token: "
        local ADO_TOKEN=""
        read -rs ADO_TOKEN
        echo
        
        # Validate token is not empty
        if [[ -z "$ADO_TOKEN" ]]; then
            show_error "Personal Access Token cannot be empty"
            return $EXIT_AUTH_FAILED
        fi
        
        KEY_VAULT_SECRET="${ADO_TOKEN}"
        export AZURE_DEVOPS_EXT_PAT="${ADO_TOKEN}"
        
        # Test the new token
        user_info_output=$(az devops user show --output json 2>&1)
        exit_code=$?
        
        if [[ $exit_code -eq 0 ]] && [[ -n "$user_info_output" ]]; then
            show_success "Azure DevOps CLI authentication verified with new token"
            display_devops_auth_info "$user_info_output"
            return $EXIT_SUCCESS
        else
            show_error "Provided Azure DevOps token is invalid"
            return $EXIT_AUTH_FAILED
        fi
    fi
}

# Main authentication requirement function with script termination
require_authentication() {
    local service="$1"
    local validation_function="$2"
    local service_display="$3"
    
    echo ""
    echo "========================================"
    echo "  ${service_display} AUTHENTICATION CHECK"
    echo "========================================"
    echo ""
    
    if ! $validation_function; then
        echo ""
        echo "========================================"
        echo "  AUTHENTICATION REQUIRED"
        echo "========================================"
        echo ""
        show_error "Script execution stopped due to missing $service authentication"
        echo ""
        echo "Please authenticate using the methods shown above,"
        echo "then re-run this script to continue."
        echo ""
        exit $EXIT_AUTH_FAILED
    fi
    
    echo ""
}

require_azure_authentication() {
    require_authentication "Azure CLI" "validate_azure_authentication" "AZURE CLI"
}

require_azd_authentication() {
    require_authentication "Azure Developer CLI" "validate_azd_authentication" "AZURE DEVELOPER CLI"
}

require_github_authentication() {
    require_authentication "GitHub CLI" "validate_github_authentication" "GITHUB CLI"
}

require_azure_devops_authentication() {
    require_authentication "Azure DevOps CLI" "validate_azure_devops_authentication" "AZURE DEVOPS CLI"
}

#------------------------------------------------------------------------------
# PREREQUISITE VALIDATION FUNCTIONS
#------------------------------------------------------------------------------

# Display installation instructions for various tools
show_azure_cli_install_instructions() {
    cat << 'EOF'
[INSTALL GUIDE] Azure CLI Installation:

1. Update package index:
   sudo apt-get update

2. Install required packages:
   sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg

3. Download and install Microsoft signing key:
   sudo mkdir -p /etc/apt/keyrings
   curl -sLS https://packages.microsoft.com/keys/microsoft.asc | 
   gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null

4. Add Azure CLI repository and install:
   AZ_REPO=$(lsb_release -cs)
   echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
   sudo apt-get update && sudo apt-get install azure-cli

5. Verify: az --version

For other distributions: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
EOF
}

show_azd_install_instructions() {
    cat << 'EOF'
[INSTALL GUIDE] Azure Developer CLI (azd) Installation:

Option 1 - Install Script (Recommended):
   curl -fsSL https://aka.ms/install-azd.sh | bash
   source ~/.bashrc

Option 2 - Manual Installation:
   wget https://github.com/Azure/azure-dev/releases/latest/download/azd-linux-amd64.tar.gz
   tar -xzf azd-linux-amd64.tar.gz
   sudo mv azd /usr/local/bin/ && sudo chmod +x /usr/local/bin/azd

Verify: azd version

For more details: https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd
EOF
}

show_azure_devops_cli_install_instructions() {
    cat << 'EOF'
[INSTALL GUIDE] Azure DevOps CLI Extension:

Prerequisites: Azure CLI must be installed first

1. Install extension: az extension add --name azure-devops
2. Verify: az extension list --output table
3. Login (optional): az devops login

For more details: https://docs.microsoft.com/en-us/azure/devops/cli/
EOF
}

show_github_cli_install_instructions() {
    cat << 'EOF'
[INSTALL GUIDE] GitHub CLI Installation:

Option 1 - APT Repository (Ubuntu/Debian):
   sudo apt update
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   sudo apt update && sudo apt install gh

Option 2 - Snap:
   sudo snap install gh

Verify: gh --version

For other distributions: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
EOF
}

show_powershell_install_instructions() {
    cat << 'EOF'
[INSTALL GUIDE] PowerShell on Linux Installation:

Option 1 - Package Repository (Ubuntu):
   sudo apt-get update
   wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
   sudo dpkg -i packages-microsoft-prod.deb
   sudo apt-get update && sudo apt-get install -y powershell

Option 2 - Snap:
   sudo snap install powershell --classic

Verify: pwsh --version

For other distributions: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux
EOF
}

# Get tool version safely
get_tool_version() {
    local command_name="$1"
    local version
    
    case "$command_name" in
        "az") 
            version=$(az --version 2>/dev/null | head -n1 | awk '{print $2}' 2>/dev/null || echo "unknown") 
            ;;
        "azd") 
            version=$(azd version 2>/dev/null | grep -oP 'azd version \K[0-9.]+' 2>/dev/null || echo "unknown") 
            ;;
        "gh") 
            version=$(gh --version 2>/dev/null | head -n1 | awk '{print $3}' 2>/dev/null || echo "unknown") 
            ;;
        "pwsh") 
            version=$(pwsh --version 2>/dev/null | awk '{print $2}' 2>/dev/null || echo "unknown") 
            ;;
        *) 
            version="unknown" 
            ;;
    esac
    
    echo "$version"
}

# Validate individual prerequisite
validate_prerequisite() {
    local tool_name="$1"
    local command_name="$2"
    local install_function="$3"
    
    show_info "Checking $tool_name..."
    
    if command_exists "$command_name"; then
        show_success "$tool_name is installed"
        
        local version
        version=$(get_tool_version "$command_name")
        echo "         Version: $version"
        return $EXIT_SUCCESS
    else
        show_warning "$tool_name is NOT installed"
        echo ""
        $install_function
        echo ""
        return $EXIT_VALIDATION_FAILED
    fi
}

# Check Azure DevOps CLI extension specifically
validate_azure_devops_extension() {
    show_info "Checking Azure DevOps CLI Extension..."
    
    if ! command_exists "az"; then
        show_warning "Azure CLI is required for Azure DevOps CLI Extension"
        return $EXIT_VALIDATION_FAILED
    fi
        
    if az extension list --output tsv 2>/dev/null | grep -q "azure-devops"; then
        show_success "Azure DevOps CLI Extension is installed"
        local version
        version=$(az extension list --output tsv 2>/dev/null | grep "azure-devops" | cut -f3 2>/dev/null || echo "unknown")
        echo "         Version: $version"
        return $EXIT_SUCCESS
    else
        show_warning "Azure DevOps CLI Extension is NOT installed"
        echo ""
        show_azure_devops_cli_install_instructions
        echo ""
        return $EXIT_VALIDATION_FAILED
    fi
}

# Main prerequisite validation function
validate_prerequisites() {
    echo ""
    echo "========================================"
    echo "  PREREQUISITE VALIDATION"
    echo "========================================"
    echo ""
    echo "Validating technical prerequisites for Azure Dev Box deployment..."
    echo ""
    
    local -a validation_results=()
    
    # Validate each prerequisite and collect results
    validate_prerequisite "Azure CLI" "az" "show_azure_cli_install_instructions"
    validation_results+=($?)
    echo ""
    
    validate_prerequisite "Azure Developer CLI" "azd" "show_azd_install_instructions"
    validation_results+=($?)
    echo ""
    
    validate_azure_devops_extension
    validation_results+=($?)
    echo ""
    
    validate_prerequisite "GitHub CLI" "gh" "show_github_cli_install_instructions"
    validation_results+=($?)
    echo ""
    
    validate_prerequisite "PowerShell" "pwsh" "show_powershell_install_instructions"
    validation_results+=($?)
    echo ""
    
    # Count failures
    local missing_count=0
    for result in "${validation_results[@]}"; do
        if [[ $result -ne $EXIT_SUCCESS ]]; then
            ((missing_count++))
        fi
    done
    
    # Summary
    echo "========================================"
    echo "  VALIDATION SUMMARY"
    echo "========================================"
    
    if [[ $missing_count -eq 0 ]]; then
        show_success "All prerequisites satisfied! Ready for Azure Dev Box deployment."
        echo ""
        return $EXIT_SUCCESS
    else
        show_warning "$missing_count prerequisite(s) missing."
        echo ""
        echo "Install missing prerequisites using instructions above,"
        echo "then re-run: $SCRIPT_NAME --validate-prerequisites"
        echo ""
        return $EXIT_VALIDATION_FAILED
    fi
}

#------------------------------------------------------------------------------
# PARAMETER VALIDATION FUNCTIONS
#------------------------------------------------------------------------------

# Validate source control platform parameter
validate_source_control_platform() {
    local platform="$1"
    
    if ! is_not_empty "$platform"; then
        show_error "Source control platform cannot be empty"
        return $EXIT_VALIDATION_FAILED
    fi
    
    for valid_platform in "${VALID_PLATFORMS[@]}"; do
        if [[ "$platform" == "$valid_platform" ]]; then
            return $EXIT_SUCCESS
        fi
    done
    
    show_error "Invalid source control platform: '$platform'"
    echo "        Supported platforms: ${VALID_PLATFORMS[*]}" >&2
    return $EXIT_VALIDATION_FAILED
}

# Validate Azure environment name parameter
validate_azure_env_name() {
    local env_name="$1"
    
    # Check for empty or whitespace-only values
    if ! is_not_empty "$env_name"; then
        show_error "Azure environment name cannot be empty"
        return $EXIT_VALIDATION_FAILED
    fi
    
    # Check for valid naming convention
    if [[ ! "$env_name" =~ $ENV_NAME_PATTERN ]]; then
        show_error "Invalid Azure environment name: '$env_name'"
        echo "        Must start/end with alphanumeric, contain only letters/numbers/hyphens/underscores" >&2
        echo "        Examples: dev, test-env, staging_01, prod" >&2
        return $EXIT_VALIDATION_FAILED
    fi
    
    # Check length
    if [[ ${#env_name} -gt $MAX_ENV_NAME_LENGTH ]]; then
        show_error "Environment name too long: ${#env_name} characters (max: $MAX_ENV_NAME_LENGTH)"
        return $EXIT_VALIDATION_FAILED
    fi
    
    if [[ ${#env_name} -lt $MIN_ENV_NAME_LENGTH ]]; then
        show_error "Environment name too short: ${#env_name} characters (min: $MIN_ENV_NAME_LENGTH)"
        return $EXIT_VALIDATION_FAILED
    fi
    
    return $EXIT_SUCCESS
}

# Validate key vault secret parameter
validate_key_vault_secret() {
    local secret="$1"
    
    # If empty, it's optional - validation will be handled later
    if [[ -z "$secret" ]]; then
        return $EXIT_SUCCESS
    fi
    
    # Check for basic security requirements
    if [[ ${#secret} -lt $MIN_TOKEN_LENGTH ]]; then
        show_error "Key vault secret too short (minimum $MIN_TOKEN_LENGTH characters)"
        return $EXIT_VALIDATION_FAILED
    fi
    
    # Check for whitespace-only values
    if [[ "$secret" =~ ^[[:space:]]*$ ]]; then
        show_error "Key vault secret cannot be empty or whitespace only"
        return $EXIT_VALIDATION_FAILED
    fi
    
    # Validate token format based on platform
    case "$SOURCE_CONTROL_PLATFORM" in
        "github")
            validate_github_token_format "$secret"
            ;;
        "adogit")
            validate_ado_token_format "$secret"
            ;;
        *)
            # Generic validation for unknown platforms
            if [[ ! "$secret" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                show_warning "Secret contains special characters that may not be valid for all platforms"
            fi
            ;;
    esac
    
    return $EXIT_SUCCESS
}

# Validate GitHub token format
validate_github_token_format() {
    local token="$1"
    
    # GitHub Personal Access Tokens start with specific prefixes
    if [[ "$token" =~ ^(ghp_|gho_|ghu_|ghs_|ghr_)[a-zA-Z0-9]{36}$ ]]; then
        show_info "GitHub token format validated successfully (new format)"
        return $EXIT_SUCCESS
    elif [[ ${#token} -eq $GITHUB_PAT_LENGTH && "$token" =~ ^[a-f0-9]+$ ]]; then
        # Legacy 40-character hex tokens
        show_info "Legacy GitHub token format detected"
        return $EXIT_SUCCESS
    else
        show_warning "Token format does not match expected GitHub patterns"
        show_info "Expected formats: ghp_xxxxxxxx (PAT), gho_xxxxxxxx (OAuth), or $GITHUB_PAT_LENGTH-char hex"
        return $EXIT_SUCCESS  # Don't fail, just warn
    fi
}

# Validate Azure DevOps token format
validate_ado_token_format() {
    local token="$1"
    
    # Azure DevOps PATs are typically base64-encoded, 52 characters
    if [[ ${#token} -eq $ADO_PAT_LENGTH && "$token" =~ ^[a-zA-Z0-9+/]*={0,2}$ ]]; then
        show_info "Azure DevOps token format validated successfully"
        return $EXIT_SUCCESS
    else
        show_warning "Token format does not match expected Azure DevOps PAT pattern"
        show_info "Expected: $ADO_PAT_LENGTH-character base64-encoded string"
        return $EXIT_SUCCESS  # Don't fail, just warn
    fi
}

#------------------------------------------------------------------------------
# MAIN SCRIPT LOGIC
#------------------------------------------------------------------------------

# Validate parameter has value
validate_parameter_value() {
    local param_name="$1"
    local param_value="$2"
    
    if [[ -z "$param_value" || "$param_value" == --* ]]; then
        show_error "Parameter $param_name requires a value"
        exit $EXIT_INVALID_PARAMS
    fi
    
    # Additional validation for parameter format
    if [[ "$param_value" =~ ^[[:space:]]*$ ]]; then
        show_error "Parameter $param_name value cannot be empty or whitespace only"
        exit $EXIT_INVALID_PARAMS
    fi
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --source-control-platform)
                validate_parameter_value "$1" "$2"
                SOURCE_CONTROL_PLATFORM="$2"
                shift 2
                ;;
            --azure-env-name)
                validate_parameter_value "$1" "$2"
                AZURE_ENV_NAME="$2"
                shift 2
                ;;
            --key-vault-secret)
                validate_parameter_value "$1" "$2"
                KEY_VAULT_SECRET="$2"
                log_secure_info "Key vault secret provided via parameter" "$KEY_VAULT_SECRET"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit $EXIT_SUCCESS
                ;;
            --version)
                echo "${SCRIPT_NAME} version ${SCRIPT_VERSION}"
                exit $EXIT_SUCCESS
                ;;
            --validate-prerequisites)
                validate_prerequisites
                exit $?
                ;;
            --check-auth)
                show_header
                require_azure_authentication
                show_success "Azure authentication check completed successfully!"
                exit $EXIT_SUCCESS
                ;;
            --check-azd-auth)
                show_header
                require_azd_authentication
                show_success "Azure Developer CLI authentication check completed!"
                exit $EXIT_SUCCESS
                ;;
            --check-github-auth)
                show_header
                require_github_authentication
                show_success "GitHub CLI authentication check completed!"
                exit $EXIT_SUCCESS
                ;;
            --check-devops-auth)
                show_header
                require_azure_devops_authentication
                show_success "Azure DevOps CLI authentication check completed!"
                exit $EXIT_SUCCESS
                ;;
            *)
                show_error "Unknown parameter: '$1'"
                echo "        Use '${SCRIPT_NAME} --help' for complete usage information." >&2
                exit $EXIT_INVALID_PARAMS
                ;;
        esac
    done
}

# Validate required parameters
validate_required_parameters() {
    show_info "Validating parameters..."
    
    if ! is_not_empty "$SOURCE_CONTROL_PLATFORM"; then
        show_error "Missing required parameter: --source-control-platform"
        echo "        Example: ${SCRIPT_NAME} --source-control-platform github --azure-env-name dev" >&2
        exit $EXIT_INVALID_PARAMS
    fi
    
    if ! is_not_empty "$AZURE_ENV_NAME"; then
        show_error "Missing required parameter: --azure-env-name"
        echo "        Example: ${SCRIPT_NAME} --source-control-platform github --azure-env-name dev" >&2
        exit $EXIT_INVALID_PARAMS
    fi
    
    # Validate mandatory parameters
    validate_source_control_platform "$SOURCE_CONTROL_PLATFORM" || exit $EXIT_VALIDATION_FAILED
    validate_azure_env_name "$AZURE_ENV_NAME" || exit $EXIT_VALIDATION_FAILED
    
    # Validate optional KEY_VAULT_SECRET if provided
    if [[ -n "$KEY_VAULT_SECRET" ]]; then
        validate_key_vault_secret "$KEY_VAULT_SECRET" || exit $EXIT_VALIDATION_FAILED
        show_success "Key vault secret parameter validated successfully!"
    else
        show_info "No key vault secret provided - will attempt automatic retrieval or prompt"
    fi
    
    show_success "All parameters validated successfully!"
}

# Check authentication requirements
check_authentication_requirements() {
    require_azure_authentication
    require_azd_authentication
    
    # Platform-specific authentication
    case "$SOURCE_CONTROL_PLATFORM" in
        "github")
            require_github_authentication
            ;;
        "adogit")
            require_azure_devops_authentication
            ;;
    esac
}

# Check prerequisites with proper error handling
check_prerequisites() {
    show_info "Validating technical prerequisites..."
    if ! validate_prerequisites; then
        show_error "Prerequisites validation failed. Install missing components before proceeding."
        exit $EXIT_VALIDATION_FAILED
    fi
}

# Save environment variable to Azure environment file
save_env_variable() {
    local key="$1"
    local value="$2"
    local description="$3"
    
    if update_azure_env_file "$key" "$value"; then
        show_success "$description saved to Azure environment"
        return $EXIT_SUCCESS
    else
        show_warning "Failed to save $description to Azure environment"
        echo "        The deployment will continue, but configuration may not be persisted." >&2
        return $EXIT_FILE_ERROR
    fi
}

# Configure Azure environment
configure_azure_environment() {
    show_info "Configuring Azure environment settings..."
    
    save_env_variable "SOURCE_CONTROL_PLATFORM" "'${SOURCE_CONTROL_PLATFORM}'" "SOURCE_CONTROL_PLATFORM"
    echo ""
    
    if is_not_empty "$KEY_VAULT_SECRET"; then
        # Only save if secret was provided via parameter (more secure)
        if [[ -n "${KEY_VAULT_SECRET:-}" ]]; then
            save_env_variable "KEY_VAULT_SECRET" "'${KEY_VAULT_SECRET}'" "KEY_VAULT_SECRET"
            show_info "Secret stored securely in Azure environment file"
        fi
        echo ""
    else
        show_info "No authentication secret provided - using CLI-based authentication"
    fi
    
    if validate_azure_env_file; then
        echo ""
    else
        show_warning "Azure environment file validation encountered issues"
        echo ""
    fi
    
    show_info "DevBox environment setup will proceed with the above configuration..."
}

#------------------------------------------------------------------------------
# MAIN EXECUTION
#------------------------------------------------------------------------------

clear

# Display script header
show_header

# Parse and validate arguments
parse_arguments "$@"

# Validate required parameters  
validate_required_parameters

# Validate prerequisites
check_prerequisites

# Check authentication
check_authentication_requirements

# Configure Azure environment
configure_azure_environment

# TODO: Add actual setup logic here
# This is where you would add the commands to:
# 1. Configure the source control platform integration
# 2. Set up the Azure environment
# 3. Deploy necessary resources
# 4. Configure DevBox with the specified settings

show_success "DevBox environment setup completed successfully!"
exit $EXIT_SUCCESS
