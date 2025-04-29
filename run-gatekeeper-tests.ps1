$ErrorActionPreference = "SilentlyContinue"

# Step 1: Apply all ConstraintTemplates
Write-Host "`n Applying ConstraintTemplates..." -ForegroundColor Cyan
kubectl apply -f gatekeeper-tests/constraints/disallow-privileged-template.yaml
kubectl apply -f gatekeeper-tests/constraints/require-labels-template.yaml
kubectl apply -f gatekeeper-tests/constraints/disallow-imagepullpolicy-always-template.yaml

# Step 2: Apply all Constraints (based on the templates)
Write-Host "`n Applying Constraints..." -ForegroundColor Cyan
kubectl apply -f gatekeeper-tests/constraints/disallow-privileged.yaml
kubectl apply -f gatekeeper-tests/constraints/require-labels.yaml
kubectl apply -f gatekeeper-tests/constraints/disallow-imagepullpolicy-always.yaml

# Function to test each manifest and display pass/fail
function Test-Manifest {
    param (
        [string]$Path
    )

    Write-Host "`n Testing: $Path" -ForegroundColor Yellow
    $result = kubectl apply -f $Path 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "PASSED: $Path" -ForegroundColor Green
    } else {
        Write-Host "BLOCKED: $Path" -ForegroundColor Red
        Write-Host "$result" -ForegroundColor DarkGray
    }
}

# Step 3: Execute all policy tests
Write-Host "`n Running policy tests..." -ForegroundColor Cyan

$testFiles = @(
    "pod-missing-labels.yaml",
    "pod-ok-labels.yaml",
    "pod-imagepull-always.yaml",
    "pod-ok-imagepull.yaml",
    "deployment-privileged.yaml",
    "deployment-ok.yaml"
)

foreach ($file in $testFiles) {
    Test-Manifest -Path "gatekeeper-tests/manifests/$file"
}

# Step 4: Clean up all test resources
Write-Host "`n Cleaning up test resources..."

Get-ChildItem -Path "gatekeeper-tests/manifests" -Filter *.yaml | ForEach-Object {
    $manifest = $_.FullName
    Write-Host "  Deleting: $manifest"
    kubectl delete -f $manifest --ignore-not-found
}

Write-Host "Cleanup complete.`n"

# Step 5: Display a quick summary of active templates
Write-Host "`n Policy summary (via kubectl explain):`n"

$templates = @(
    "constrainttemplate.templates.gatekeeper.sh/k8sdisallowprivileged",
    "constrainttemplate.templates.gatekeeper.sh/k8srequirelabels",
    "constrainttemplate.templates.gatekeeper.sh/k8sdisallowimagepullpolicyalways"
)

foreach ($template in $templates) {
    Write-Host "Template: $template"
    kubectl explain $template 2>$null | Select-String "KIND" -Context 0,2
    Write-Host ""
}
