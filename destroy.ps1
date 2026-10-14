<#
.SYNOPSIS
    Destroy a specific environment using Terraform.

.DESCRIPTION
    Safely tears down a single environment by switching to its
    Terraform workspace and destroying only that environment's resources.

.PARAMETER Environment
    The environment to destroy: qa, uat, or prod.

.EXAMPLE
    .\destroy.ps1 -Environment qa
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("qa", "uat", "prod")]
    [string]$Environment
)

$ErrorActionPreference = "Stop"
$terraformDir = Join-Path $PSScriptRoot "terraform"
$tfvarsFile   = Join-Path $terraformDir "environments" "$Environment.tfvars"

Write-Host "`n========================================" -ForegroundColor Red
Write-Host " Destroying: $($Environment.ToUpper()) environment" -ForegroundColor Red
Write-Host "========================================`n" -ForegroundColor Red

Write-Host "Are you sure you want to destroy the $($Environment.ToUpper()) environment? (y/N): " -ForegroundColor Yellow -NoNewline
$confirm = Read-Host
if ($confirm -ne 'y' -and $confirm -ne 'Y') {
    Write-Host "Aborted." -ForegroundColor Yellow
    exit 0
}

Push-Location $terraformDir

try {
    terraform init -input=false
    terraform workspace select $Environment
    terraform destroy -var-file="environments/$Environment.tfvars" -auto-approve

    Write-Host "`n$($Environment.ToUpper()) environment destroyed." -ForegroundColor Green
} finally {
    Pop-Location
}
