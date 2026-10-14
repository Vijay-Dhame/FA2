<#
.SYNOPSIS
    Deploy the DevOps Environment Manager to local Kubernetes (Docker Desktop).

.DESCRIPTION
    This script builds Docker images, tags them for GHCR, and deploys all
    Kubernetes manifests including the monitoring stack (Prometheus + Grafana).
    Use this for local development/demonstration when the CI/CD pipeline
    cannot reach the local cluster.

.EXAMPLE
    .\deploy-k8s.ps1
#>

$ErrorActionPreference = "Stop"
$projectRoot = $PSScriptRoot

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " FA2: Deploying to Local Kubernetes" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# --- Pre-flight checks ---
Write-Host "[0/8] Pre-flight checks..." -ForegroundColor Yellow
try {
    kubectl cluster-info 2>&1 | Out-Null
    Write-Host "  ✓ Kubernetes cluster is reachable" -ForegroundColor Green
} catch {
    Write-Error "Kubernetes cluster is not reachable. Enable Kubernetes in Docker Desktop Settings."
    exit 1
}

$context = kubectl config current-context
Write-Host "  ✓ Current context: $context" -ForegroundColor Green

# --- Build Docker images ---
Write-Host "`n[1/8] Building Docker images..." -ForegroundColor Yellow
$sha = (git rev-parse --short HEAD)
$backendImage = "ghcr.io/vijay-dhame/fa2-backend"
$frontendImage = "ghcr.io/vijay-dhame/fa2-frontend"

docker build -t "${backendImage}:${sha}" -t "${backendImage}:latest" "$projectRoot/backend"
Write-Host "  ✓ Backend image built: ${backendImage}:${sha}" -ForegroundColor Green

docker build -t "${frontendImage}:${sha}" -t "${frontendImage}:latest" "$projectRoot/frontend"
Write-Host "  ✓ Frontend image built: ${frontendImage}:${sha}" -ForegroundColor Green

# --- Create namespace ---
Write-Host "`n[2/8] Creating namespace..." -ForegroundColor Yellow
kubectl apply -f "$projectRoot/k8s/namespace.yaml"

# --- Apply ConfigMap ---
Write-Host "`n[3/8] Applying ConfigMap..." -ForegroundColor Yellow
kubectl apply -f "$projectRoot/k8s/configmap.yaml"

# --- Deploy backend ---
Write-Host "`n[4/8] Deploying backend..." -ForegroundColor Yellow
kubectl apply -f "$projectRoot/k8s/backend-deployment.yaml"
kubectl apply -f "$projectRoot/k8s/backend-service.yaml"

# --- Deploy frontend ---
Write-Host "`n[5/8] Deploying frontend..." -ForegroundColor Yellow
kubectl apply -f "$projectRoot/k8s/frontend-deployment.yaml"
kubectl apply -f "$projectRoot/k8s/frontend-service.yaml"

# --- Deploy monitoring ---
Write-Host "`n[6/8] Deploying monitoring stack..." -ForegroundColor Yellow
kubectl apply -f "$projectRoot/k8s/monitoring/prometheus-config.yaml"
kubectl apply -f "$projectRoot/k8s/monitoring/prometheus-deployment.yaml"
kubectl apply -f "$projectRoot/k8s/monitoring/prometheus-service.yaml"
kubectl apply -f "$projectRoot/k8s/monitoring/grafana-provisioning/datasource.yaml"
kubectl apply -f "$projectRoot/k8s/monitoring/grafana-provisioning/dashboard-provider.yaml"
kubectl apply -f "$projectRoot/k8s/monitoring/grafana-dashboard-configmap.yaml"
kubectl apply -f "$projectRoot/k8s/monitoring/grafana-deployment.yaml"
kubectl apply -f "$projectRoot/k8s/monitoring/grafana-service.yaml"

# --- Wait for rollouts ---
Write-Host "`n[7/8] Waiting for rollouts..." -ForegroundColor Yellow
kubectl rollout status deployment/backend   -n devops-fa2 --timeout=120s
kubectl rollout status deployment/frontend  -n devops-fa2 --timeout=120s
kubectl rollout status deployment/prometheus -n devops-fa2 --timeout=120s
kubectl rollout status deployment/grafana   -n devops-fa2 --timeout=120s

# --- Show status ---
Write-Host "`n[8/8] Deployment status:" -ForegroundColor Yellow
kubectl get all -n devops-fa2

Write-Host "`n========================================" -ForegroundColor Green
Write-Host " FA2 Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Frontend:    http://localhost:30080" -ForegroundColor Cyan
Write-Host "  Backend API: http://localhost:30080/health" -ForegroundColor Cyan
Write-Host "  Prometheus:  http://localhost:30090" -ForegroundColor Cyan
Write-Host "  Grafana:     http://localhost:30030  (admin/admin)" -ForegroundColor Cyan
Write-Host ""
