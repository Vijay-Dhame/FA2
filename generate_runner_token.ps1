param(
    [Parameter(Mandatory=$false)]
    [string]$Pat = $env:GITHUB_PAT,
    [Parameter(Mandatory=$false)]
    [string]$Repo = "Vijay-Dhame/FA2"
)

if (-not $Pat) {
    Write-Error "Please provide -Pat or set GITHUB_PAT environment variable."
    exit 1
}

$headers = @{
    Authorization = "token $Pat"
    Accept = 'application/vnd.github+json'
}
$response = Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/actions/runners/registration-token" -Method POST -Headers $headers
Write-Output $response.token
