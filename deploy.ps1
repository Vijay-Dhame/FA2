<#
.SYNOPSIS
    Deploy a specific environment using Terraform with isolated state.

.DESCRIPTION
    This script deploys QA, UAT, or PROD using Terraform workspaces
    for state isolation. Each workspace has its own .tfstate file
    so deploying one environment does not affect others.

.PARAMETER Environment
    The environment to deploy: qa, uat, or prod.

.EXAMPLE
    .\deploy.ps1 -Environment qa
    .\deploy.ps1 -Environment uat
    .\deploy.ps1 -Environment prod
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("qa", "uat", "prod")]
    [string]$Environment
)

$ErrorActionPreference = "Stop"
$terraformDir = Join-Path $PSScriptRoot "terraform"
$tfvarsFile   = Join-Path $terraformDir "environments" "$Environment.tfvars"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " Deploying: $($Environment.ToUpper()) environment" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Ensure tfvars file exists
if (-not (Test-Path $tfvarsFile)) {
    Write-Error "tfvars file not found: $tfvarsFile"
    exit 1
}

# Navigate to terraform directory
Push-Location $terraformDir

try {
    # Initialize Terraform (idempotent)
    Write-Host "[1/5] Initializing Terraform..." -ForegroundColor Yellow
    terraform init -input=false

    # Select or create workspace
    Write-Host "`n[2/5] Selecting workspace: $Environment" -ForegroundColor Yellow
    $existingWorkspaces = terraform workspace list 2>&1
    if ($existingWorkspaces -match "\b$Environment\b") {
        terraform workspace select $Environment
    } else {
        terraform workspace new $Environment
    }

    # Validate configuration
    Write-Host "`n[3/5] Validating configuration..." -ForegroundColor Yellow
    terraform validate

    # Plan
    Write-Host "`n[4/5] Planning deployment..." -ForegroundColor Yellow
    terraform plan -var-file="environments/$Environment.tfvars" -out="$Environment.tfplan"

    # Apply
    Write-Host "`n[5/5] Applying deployment..." -ForegroundColor Yellow
    terraform apply -auto-approve "$Environment.tfplan"

    # Show outputs
    Write-Host "`n========================================" -ForegroundColor Green
    Write-Host " $($Environment.ToUpper()) Deployment Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    terraform output

} finally {
    Pop-Location
}
