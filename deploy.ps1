# 1. Set environmental variables
$trivyPath = "D:\tools\apps\trivy\current\trivy.exe"
$acrName = "acrexamensarbete"
$resourceGroup = "rg-examensarbete-secuflow"
$aksClusterName = "aks-examensarbete"
$deploymentNamespace = "examensarbete-app"
$imageName = "secuflow:v3"
$imageUri = "$acrName.azurecr.io/$imageName"
$deploymentFilePath = "D:\repos\secuflow\deployment.yaml"

# 2. Build Docker-image
Write-Host "Build Docker image..."
docker build -t $imageUri .

# 3. Log in to ACR
Write-Host "Logging in to ACR..."
az acr login --name $acrName

# 4. Push Docker-image
Write-Host "Pushing image to ACR..."
docker push $imageUri

# 5. Trivy Image Scanning
Write-Host "Using Trivy Image Scanning..."
& $trivyPath image $imageUri --scanners vuln --skip-dirs ./trivy-results

# 6. Get AKS credentials
Write-Host "Getting AKS credentials..."
az aks get-credentials --resource-group $resourceGroup --name $aksClusterName

# 7. Apply OPA Gatekeeper ConstraintTemplates and Constraints
Write-Host "Applying Gatekeeper ConstraintTemplates and Constraints..."

# Apply all templates
kubectl apply -f ".\gatekeeper-tests\constraints\disallow-privileged-template.yaml"
kubectl apply -f ".\gatekeeper-tests\constraints\require-labels-template.yaml"
kubectl apply -f ".\gatekeeper-tests\constraints\disallow-imagepullpolicy-always-template.yaml"

# Apply all constraints
kubectl apply -f ".\gatekeeper-tests\constraints\disallow-privileged.yaml"
kubectl apply -f ".\gatekeeper-tests\constraints\require-labels.yaml"
kubectl apply -f ".\gatekeeper-tests\constraints\disallow-imagepullpolicy-always.yaml"


# 8. Apply Deployment
Write-Host "Applying initial deployment YAML..."
kubectl apply -f $deploymentFilePath -n $deploymentNamespace

# 9. Uppdate image in deployment
Write-Host "Set image on AKS deployment..."
kubectl set image deployment/examensarbete-app examensarbete=$imageUri -n $deploymentNamespace

Write-Host "Deployment is finished!"
