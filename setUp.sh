#!/usr/bin/env bash

# setUp.sh - Sets up Azure Dev Box environment with GitHub integration
#
# DESCRIPTION
#     Automates the setup of an Azure Developer CLI (azd) environment for Dev Box,
#     handles GitHub authentication, and provisions required Azure resources.
#
#     This script follows Azure best practices for security, error handling, 
#     and resource management.
#
# PARAMETERS
#     -e, --env-name       Name of the Azure environment to create
#     -s, --source-control Source control platform (github or adogit)
#     -h, --help          Show this help message
#
# EXAMPLES
#     ./setUp.sh -e "prod" -s "github"
#     # Creates a "prod" environment with GitHub
#     
#     ./setUp.sh -e "dev" -s "adogit"
#     # Creates a "dev" environment with Azure DevOps
#
# REQUIREMENTS
#     - Azure CLI (az)
#     - Azure Developer CLI (azd)
#     - GitHub CLI (gh) [if using GitHub]
#     - jq (JSON processor)
#     - Valid authentication for chosen platform
#
# EXIT CODES
#     0   - Success
#     1   - General error (missing dependencies, validation failure)
#     130 - Script interrupted by user (SIGINT/SIGTERM)
#     
# Author: DevExp Team
# Last Updated: 2026-01-22

# Script Configuration
set -euo pipefail  # Exit on error, undefined vars, pipe failures
IFS=$'\n\t'       # Secure Internal Field Separator

# Global Variables
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TIMESTAMP_FORMAT="%Y-%m-%d %H:%M:%S"

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Unicode icons
readonly INFO_ICON="ℹ️"
readonly WARNING_ICON="⚠️"
readonly ERROR_ICON="❌"
readonly SUCCESS_ICON="✅"

# Global variables for script state
ENV_NAME=""
SOURCE_CONTROL_PLATFORM=""
GITHUB_TOKEN=""
ADO_TOKEN=""

#######################################
# Helper Functions
#######################################

#######################################
# Outputs a formatted log message with timestamp and color coding.
#
# Arguments:
#   $1 - message: The message to display
#   $2 - level: Log level (Info, Warning, Error, Success). Default: Info
#
# Outputs:
#   Writes formatted message to stdout (or stderr for Error level)
#
# Example:
#   write_log_message "Starting process" "Info"
#   write_log_message "Something went wrong" "Error"
#######################################
write_log_message() {
    local message="$1"
    local level="${2:-Info}"
    local timestamp
    timestamp=$(date +"$TIMESTAMP_FORMAT")
    
    case "$level" in
        "Error")
            echo -e "${ERROR_ICON} ${RED}[$timestamp] $message${NC}" >&2
            ;;
        "Warning")
            echo -e "${WARNING_ICON} ${YELLOW}[$timestamp] $message${NC}"
            ;;
        "Success")
            echo -e "${SUCCESS_ICON} ${GREEN}[$timestamp] $message${NC}"
            ;;
        "Info"|*)
            echo -e "${INFO_ICON} ${CYAN}[$timestamp] $message${NC}"
            ;;
    esac
}

#######################################
# Checks if a command is available in the system PATH.
#
# Arguments:
#   $1 - command: The command name to check
#
# Returns:
#   0 - Command is available
#   1 - Command not found
#
# Example:
#   if test_command_availability "az"; then
#     echo "Azure CLI is installed"
#   fi
#######################################
test_command_availability() {
    local command="$1"
    
    if ! command -v "$command" &> /dev/null; then
        write_log_message "Required command '$command' was not found. Please install it before continuing." "Error"
        return 1
    fi
    return 0
}

#######################################
# Displays the help message with usage instructions.
#
# Arguments:
#   None
#
# Outputs:
#   Writes usage information to stdout
#######################################
show_help() {
    cat << EOF
setUp.sh - Sets up Azure Dev Box environment with source control integration

USAGE:
    ./setUp.sh -e ENV_NAME -s SOURCE_CONTROL

PARAMETERS:
    -e, --env-name ENV_NAME          Name of the Azure environment to create
    -s, --source-control PLATFORM    Source control platform (github or adogit)
    -h, --help                       Show this help message

EXAMPLES:
    ./setUp.sh -e "prod" -s "github"
    ./setUp.sh -e "dev" -s "adogit"

REQUIREMENTS:
    - Azure CLI (az)
    - Azure Developer CLI (azd)
    - GitHub CLI (gh) [if using GitHub]
    - Valid authentication for chosen platform
EOF
}

#######################################
# Validates the source control platform parameter.
#
# Arguments:
#   $1 - platform: The source control platform to validate
#
# Returns:
#   0 - Valid platform (github, adogit, or empty)
#   1 - Invalid platform
#
# Example:
#   if validate_source_control "github"; then
#     echo "Valid platform"
#   fi
#######################################
validate_source_control() {
    local platform="$1"
    
    if [[ "$platform" == "github" ]] || [[ "$platform" == "adogit" ]] || [[ -z "$platform" ]]; then
        return 0
    else
        write_log_message "Invalid source control platform: $platform" "Error"
        write_log_message "Valid platforms: github, adogit" "Info"
        return 1
    fi
}

#######################################
# Authentication Functions
#######################################

#######################################
# Verifies Azure CLI authentication status and subscription state.
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Returns:
#   0 - Successfully authenticated with enabled subscription
#   1 - Not authenticated or subscription not enabled
#
# Outputs:
#   Writes subscription details to stdout on success
#######################################
test_azure_authentication() {
    local az_context
    
    write_log_message "Verifying Azure authentication..." "Info"
    
    # Redirect stderr to /dev/null to prevent error messages from displaying
    if ! az_context=$(az account show 2>/dev/null); then
        write_log_message "Not logged into Azure. Please run 'az login' first." "Error"
        return 1
    fi
    
    # Parse JSON output to check subscription state
    local subscription_name subscription_id subscription_state
    subscription_name=$(echo "$az_context" | jq -r '.name')
    subscription_id=$(echo "$az_context" | jq -r '.id')
    subscription_state=$(echo "$az_context" | jq -r '.state')
    
    # Check if subscription is enabled (Azure best practice)
    if [[ "$subscription_state" != "Enabled" ]]; then
        write_log_message "Current subscription '$subscription_name' is not in 'Enabled' state." "Error"
        return 1
    fi
    
    # Output subscription details for verification
    write_log_message "Using Azure subscription: $subscription_name (ID: $subscription_id)" "Info"
    return 0
}

#######################################
# Verifies Azure DevOps CLI authentication status.
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Returns:
#   0 - Successfully authenticated
#   1 - Not authenticated
#######################################
test_ado_authentication() {
    write_log_message "Verifying Azure DevOps authentication..." "Info"
    
    # Check if Azure DevOps CLI is authenticated
    if ! az devops configure --list &>/dev/null; then
        write_log_message "Not logged into Azure DevOps. Please run 'az devops login' first." "Error"
        return 1
    fi
    
    write_log_message "Azure DevOps authentication verified successfully" "Success"
    return 0
}

#######################################
# Verifies GitHub CLI authentication status.
#
# Globals:
#   None
#
# Arguments:
#   None
#
# Returns:
#   0 - Successfully authenticated
#   1 - Not authenticated
#######################################
test_github_authentication() {
    write_log_message "Verifying GitHub authentication..." "Info"
    
    # Check if GitHub CLI is authenticated
    if ! gh auth status &>/dev/null; then
        write_log_message "Not logged into GitHub. Please run 'gh auth login' first." "Error"
        return 1
    fi
    
    write_log_message "GitHub authentication verified successfully" "Success"
    return 0
}

#######################################
# Retrieves GitHub token securely from environment or gh CLI.
#
# Globals:
#   GITHUB_TOKEN - Set with the retrieved token
#   KEY_VAULT_SECRET - Checked first, set if retrieved from gh CLI
#
# Arguments:
#   None
#
# Returns:
#   0 - Token retrieved successfully
#   1 - Failed to retrieve token
#######################################
get_secure_github_token() {
    write_log_message "Retrieving GitHub token..." "Info"

    # Check if KEY_VAULT_SECRET environment variable is already set
    if [[ -n "${KEY_VAULT_SECRET:-}" ]]; then
        write_log_message "Using existing KEY_VAULT_SECRET from environment" "Info"
        GITHUB_TOKEN="${KEY_VAULT_SECRET}"
    else
        # Retrieve GitHub token using gh CLI
        if ! GITHUB_TOKEN=$(gh auth token 2>/dev/null); then
            write_log_message "Failed to retrieve GitHub token" "Error"
            return 1
        fi
        # Export as environment variable for future use
        export KEY_VAULT_SECRET="${GITHUB_TOKEN}"
    fi
    
    if [[ -z "$GITHUB_TOKEN" ]]; then
        write_log_message "Failed to retrieve GitHub token" "Error"
        return 1
    fi
    
    write_log_message "GitHub token retrieved and stored securely" "Success"
    return 0
}

#######################################
# Retrieves Azure DevOps PAT securely from environment or user input.
#
# Globals:
#   ADO_TOKEN - Set with the retrieved token
#   KEY_VAULT_SECRET - Checked first for existing token
#   AZURE_DEVOPS_EXT_PAT - Exported with the token value
#
# Arguments:
#   None
#
# Returns:
#   0 - Token retrieved successfully
#   1 - Failed to retrieve token
#######################################
get_secure_ado_git_token() {
    write_log_message "Retrieving Azure DevOps token..." "Info"
    
    # Try to get PAT from environment variable first
    if [[ -n "${KEY_VAULT_SECRET:-}" ]]; then
        ADO_TOKEN="${KEY_VAULT_SECRET}"
        write_log_message "Azure DevOps PAT retrieved from Key Vault" "Success"
    else
        write_log_message "Azure DevOps PAT not found in environment variables." "Warning"
        write_log_message "Please enter your PAT securely." "Warning"
        
        # Prompt for PAT securely (no echo)
        echo -n "Enter your Azure DevOps Personal Access Token: "
        read -rs ADO_TOKEN
        echo
        
        # Configure Azure DevOps defaults
        if ! az devops configure --defaults organization=https://dev.azure.com/contososa2 project=DevExp-DevBox &>/dev/null; then
            write_log_message "Azure DevOps organization and project not set. Please configure them first." "Error"
            return 1
        fi
    fi
    
    if [[ -z "$ADO_TOKEN" ]]; then
        write_log_message "Failed to retrieve Azure DevOps PAT" "Error"
        return 1
    fi

    # Export the token to environment variable
    export AZURE_DEVOPS_EXT_PAT="$ADO_TOKEN"

    write_log_message "Azure DevOps PAT retrieved and stored securely" "Success"
    return 0
}

#######################################
# Azure Configuration Functions
#######################################

#######################################
# Initializes the Azure Developer CLI environment with source control token.
#
# Creates the environment directory structure and stores the appropriate
# token based on the selected source control platform.
#
# Globals:
#   ENV_NAME - Name of the environment to initialize
#   SOURCE_CONTROL_PLATFORM - Selected platform (github or adogit)
#   GITHUB_TOKEN - GitHub token (if using GitHub)
#   ADO_TOKEN - Azure DevOps token (if using adogit)
#
# Arguments:
#   None
#
# Returns:
#   0 - Environment initialized successfully
#   1 - Failed to initialize environment
#######################################
initialize_azd_environment() {
    local pat token_type masked_token
    local env_dir env_file
    
    write_log_message "Initializing Azure Developer CLI environment..." "Info"
    
    # Get appropriate token based on source control platform
    case "${SOURCE_CONTROL_PLATFORM}" in
        "github")
            write_log_message "Retrieving GitHub token for environment initialization..." "Info"
            if ! get_secure_github_token; then
                write_log_message "Unable to retrieve GitHub token. Aborting environment initialization." "Error"
                return 1
            fi
            pat="$GITHUB_TOKEN"
            token_type="GitHub"
            ;;
        "adogit")
            write_log_message "Retrieving Azure DevOps token for environment initialization..." "Info"
            if ! get_secure_ado_git_token; then
                write_log_message "Unable to retrieve Azure DevOps token. Aborting environment initialization." "Error"
                return 1
            fi
            pat="$ADO_TOKEN"
            token_type="Azure DevOps"
            ;;
        *)
            write_log_message "Unsupported source control platform: $SOURCE_CONTROL_PLATFORM" "Error"
            return 1
            ;;
    esac
    
    # Mask most of the token for security best practices
    if [[ ${#pat} -ge 8 ]]; then
        masked_token="${pat:0:4}****${pat: -2}"
    else
        masked_token="****"
    fi
    
    write_log_message "🔐 $token_type token stored securely in memory. Masked: $masked_token" "Success"
    
    # Azure best practice: Verify environment exists or use existing
    write_log_message "Using Azure Developer CLI environment: '$ENV_NAME'" "Info"
    
    # Prepare environment file path
    env_dir="./.azure/$ENV_NAME"
    env_file="$env_dir/.env"
    
    if [[ ! -d "$env_dir" ]]; then
        mkdir -p "$env_dir"
    fi
    
    # Azure best practice: Use environment-specific configuration
    write_log_message "Configuring environment variables in $env_file" "Info"
    
    # Append to existing file or create if it doesn't exist
    echo "KEY_VAULT_SECRET='$pat'" >> "$env_file"
    echo "SOURCE_CONTROL_PLATFORM='$SOURCE_CONTROL_PLATFORM'" >> "$env_file"
    
    # Show current configuration for verification
    write_log_message "Current Azure Developer CLI configuration:" "Info"
    azd config show
    
    write_log_message "Azure Developer CLI environment '$ENV_NAME' initialized successfully." "Success"
    return 0
}

#######################################
# Starts Azure resource provisioning using Azure Developer CLI.
#
# Globals:
#   ENV_NAME - Name of the environment to provision
#
# Arguments:
#   None
#
# Returns:
#   0 - Provisioning completed successfully
#   1 - Provisioning failed
#######################################
start_azure_provisioning() {
    write_log_message "Starting Azure resource provisioning with azd..." "Info"
    
    # Run the provisioning process
    if ! azd provision -e "$ENV_NAME"; then
        local exit_code=$?
        write_log_message "Azure provisioning failed with exit code $exit_code" "Error"
        
        # Provide guidance on common failures
        write_log_message "This might be a quota or permissions issue. Check your Azure subscription limits and role assignments." "Warning"
        
        return 1
    fi
    
    write_log_message "Azure provisioning completed successfully" "Success"
    return 0
}

#######################################
# Interactively prompts user to select source control platform.
#
# Globals:
#   SOURCE_CONTROL_PLATFORM - Set with user's selection
#
# Arguments:
#   None
#
# Returns:
#   Always returns 0 (loops until valid selection)
#######################################
select_source_control_platform() {
    local selection valid_selection=false
    
    write_log_message "Please select your source control platform:" "Info"
    echo ""
    echo -e "  ${YELLOW}1. Azure DevOps Git (adogit)${NC}"
    echo -e "  ${YELLOW}2. GitHub (github)${NC}"
    echo ""
    
    while [[ "$valid_selection" == false ]]; do
        echo -n "Enter your choice (1 or 2): "
        read -r selection
        
        case "$selection" in
            "1")
                SOURCE_CONTROL_PLATFORM="adogit"
                write_log_message "Selected: Azure DevOps Git" "Success"
                valid_selection=true
                ;;
            "2")
                SOURCE_CONTROL_PLATFORM="github"
                write_log_message "Selected: GitHub" "Success"
                valid_selection=true
                ;;
            *)
                write_log_message "Invalid selection. Please enter 1 or 2." "Warning"
                ;;
        esac
    done
}

#######################################
# Main Script Logic
#######################################

#######################################
# Parses command line arguments and validates required parameters.
#
# Globals:
#   ENV_NAME - Set from -e/--env-name argument
#   SOURCE_CONTROL_PLATFORM - Set from -s/--source-control argument
#
# Arguments:
#   $@ - Command line arguments passed to the script
#
# Returns:
#   0 - Arguments parsed successfully
#   Exits with 1 on validation failure
#######################################
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--env-name)
                ENV_NAME="$2"
                shift 2
                ;;
            -s|--source-control)
                SOURCE_CONTROL_PLATFORM="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                write_log_message "Unknown parameter: $1" "Error"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$ENV_NAME" ]]; then
        write_log_message "Environment name is required. Use -e or --env-name parameter." "Error"
        show_help
        exit 1
    fi
    
    # If source control not provided, prompt for it
    if [[ -z "$SOURCE_CONTROL_PLATFORM" ]]; then
        select_source_control_platform
    fi
    
    # Validate parameters
    if ! validate_source_control "$SOURCE_CONTROL_PLATFORM"; then
        exit 1
    fi
}

#######################################
# Main execution function - orchestrates the setup workflow.
#
# Performs the following steps:
#   1. Parse command line arguments
#   2. Verify required tools are installed
#   3. Verify Azure authentication
#   4. Verify source control authentication
#   5. Initialize azd environment
#
# Globals:
#   ENV_NAME - Environment name from arguments
#   SOURCE_CONTROL_PLATFORM - Platform from arguments
#
# Arguments:
#   $@ - Command line arguments passed to the script
#
# Returns:
#   0 - Setup completed successfully
#   1 - Setup failed
#######################################
main() {
    local required_tools=("az" "azd" "jq")
    local tool
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Script header with basic information
    write_log_message "Starting Dev Box environment setup" "Info"
    write_log_message "Environment name: $ENV_NAME" "Info"
    write_log_message "Source control platform: $SOURCE_CONTROL_PLATFORM" "Info"
    
    # Add GitHub CLI to required tools if using GitHub
    if [[ "$SOURCE_CONTROL_PLATFORM" == "github" ]]; then
        required_tools+=("gh")
    fi
    
    # Verify required tools - Azure best practice for dependency validation
    write_log_message "Checking required tools..." "Info"
    for tool in "${required_tools[@]}"; do
        if ! test_command_availability "$tool"; then
            write_log_message "Missing required tools. Please install them and retry." "Error"
            exit 1
        fi
    done
    write_log_message "All required tools are available" "Success"
    
    # Verify Azure authentication - Azure security best practice
    if ! test_azure_authentication; then
        exit 1
    fi
    
    # Verify source control authentication
    case "$SOURCE_CONTROL_PLATFORM" in
        "github")
            if ! test_github_authentication; then
                exit 1
            fi
            ;;
        "adogit")
            if ! test_ado_authentication; then
                exit 1
            fi
            ;;
    esac
    
    # Initialize azd environment
    if ! initialize_azd_environment; then
        write_log_message "Failed to initialize Azure Developer CLI environment. Exiting." "Error"
        exit 1
    fi
    
    # Success message with environment details
    write_log_message "Dev Box environment '$ENV_NAME' setup successfully" "Success"
    write_log_message "Access your Dev Center from the Azure portal" "Info"
    write_log_message "Use 'azd env get-values' to view environment settings" "Info"
}

# Set up error handling and cleanup
trap 'write_log_message "Script interrupted by user" "Warning"; exit 130' INT TERM

# Execute main function with all arguments
main "$@"
